require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'optparse'

options = {}
optparse = OptionParser.new do|opts|
  opts.banner = "Usage: lucky.rb [options] query1 query2 ..."

  options[:keypath] = '~/.google_key'
  credentials_text = 'A file that contains your Google API key and referrer URL'
  opts.on( '--credentials FILE', credentials_text) do|file|
    options[:keypath] = file
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

api_url = 'http://ajax.googleapis.com/ajax/services/search/web'
goog_key = ''
referrer = ''

File.open(File.expand_path(options[:keypath])) do |auth_info|
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
