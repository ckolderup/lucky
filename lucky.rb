require 'rubygems'
require 'net/http'
require 'uri'
require 'json'

if ARGV.length == 0
  puts 'Usage: lucky.rb [query] [query] ...'
  puts 'Use quotes to make a search query with multiple words.'
  puts 'Currently requires a file at ~/.google_key with your AJAX API key and domain.'
  puts 'Custom keyfile location and other output formats forthcoming.'
  exit
end

api_url = 'http://ajax.googleapis.com/ajax/services/search/web'
goog_key = ''
referrer = ''

File.open(File.expand_path('~/.google_key')) do |auth_info|
  begin
    goog_key = auth_info.gets
    referrer = auth_info.gets
  rescue
    puts 'Error in auth file. Did you forget to specify a custom location?'
    exit
  end
end

ARGV.each do |keyword|
  keyword = keyword.gsub(' ','+')
  uri = URI.parse(api_url+'?v=1.0&q='+keyword+'&key='+goog_key)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  request.initialize_http_header({'Referrer' => referrer})
  response = JSON.parse(http.request(request).body)
  link = response['responseData']['results'][0]['url']
  title = response['responseData']['results'][0]['title'].gsub(/<\/?[^>]*>/,'')
  puts '['+title+']('+link+')'
end
