require 'http'
require 'yaml'

publications = {
  # Replicates the filter types on https://www.gov.uk/government/publications
  # source: https://github.com/alphagov/whitehall/blob/master/lib/whitehall/publication_filter_option.rb

  'All consultations': ['publicationesque-consultation'],
  'Open consultations': ['consultation-open'],
  'Closed consultations': ['consultation-closed', 'consultation-outcome'],
  'Policy papers': ['publication-policy-paper'],
  'Guidance': ['publication-guidance', 'publicationesque-guidance', 'publication-statutory_guidance'],
  'Impact assessments': ['publication-impact-assessment'],
  'Independent reports': ['publication-independent-report'],
  'Correspondence': ['publication-correspondence'],
  'Research and analysis': ['publication-research-and-analysis'],
  'Statistics': ['publicationesque-statistics'],
  'Corporate reports': ['publication-corporate-report'],
  'Transparency data': ['publication-transparency-data'],
  'FOI releases': ['publication-foi-release'],
  'Forms': ['publication-form'],
  'Maps': ['publication-map'],
  'International treaties': ['publication-international-treaty'],
  'Promotional material': ['publication-promotional-material'],
  'Notices': ['publication-notice'],
  'Decisions': ['publication-decision'],
  'Regulations': ['publication-regulation'],
}

announcements =  {
  # Replicates https://www.gov.uk/government/announcements
  # https://github.com/alphagov/whitehall/blob/master/lib/whitehall/announcement_filter_option.rb
  'Press releases': ["news-article-press-release", "news-article-announcement"],
  'News stories': ["news-article-news-story", "news-article-announcement"],
  'Fatality notices': ["fatality-notice"],
  'Speeches': ["speech-transcript", "speech-draft-text", "speech-speaking-notes"],
  'Statements': ["speech-written-statement-to-parliament", "speech-statement-to-parliament", "speech-oral-statement-to-parliament", "speech-statement-to-parliament"],
  'Government responses': ["news-article-government-response"],
}

new_config = []

search_format_types = publications.values.flatten

puts "\n\n----- PUBLICATIONS -------"

query = search_format_types.map { |f| "filter_search_format_types[]=#{f}" }.join('&')
url = "https://www.gov.uk/api/search.json?count=0&#{query}&facet_content_store_document_type=100"
puts "curl #{url}"
data = JSON.parse(HTTP.get(url))
puts "Number of pages: #{data['total']}"

document_types = data.dig("facets", "content_store_document_type", "options").map { |o| o.dig("value", "slug") }
puts YAML.dump(document_types)
query = document_types.map { |f| "filter_content_store_document_type[]=#{f}" }.join('&')
url = "https://www.gov.uk/api/search.json?count=0&#{query}"
puts "curl #{url}"
data = JSON.parse(HTTP.get(url))
puts "When searching for the same: #{data["total"]}"

new_config << { 'id' => "publications", 'document_types' => document_types.sort }

search_format_types = announcements.values.flatten

puts "\n\n----- ANNOUNCE -------"

query = search_format_types.map { |f| "filter_search_format_types[]=#{f}" }.join('&')
url = "https://www.gov.uk/api/search.json?count=0&#{query}&facet_content_store_document_type=100"
puts "curl #{url}"
data = JSON.parse(HTTP.get(url))
puts "Number of pages: #{data['total']}"

document_types = data.dig("facets", "content_store_document_type", "options").map { |o| o.dig("value", "slug") }
puts YAML.dump(document_types)
query = document_types.map { |f| "filter_content_store_document_type[]=#{f}" }.join('&')
url = "https://www.gov.uk/api/search.json?count=0&#{query}"
puts "curl #{url}"
data = JSON.parse(HTTP.get(url))
puts "When searching for the same: #{data["total"]}"

new_config << { 'id' => "announcements", 'document_types' => document_types.sort }

dat = {
  "whitehall_publication_type" => {
    "default" => "other",
    "items" => new_config,
  }
}

puts YAML.dump(dat)
