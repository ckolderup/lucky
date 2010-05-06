require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'optparse'

def read_credentials(path)
  File.open(File.expand_path(path)) do |auth_info|
    goog_key = auth_info.gets
    referrer = auth_info.gets
    return goog_key+':'+referrer
  end
end

options = {}
optparse = OptionParser.new do|opts|
  opts.banner = "Usage: lucky.rb [options] query1 query2 ..."

  options[:keypath] = '~/.google_key'
  credentials_text = 'A file containing a Google API key and referrer URL'
  opts.on( '--credentials FILE', credentials_text) do|file|
    options[:keypath] = file
  end

  options[:format] = 'url'
  format_text = 'The output format (url, html, or markdown)'
  opts.on( '-f FORMAT', '--format FORMAT', format_text) do |format|
    options[:format] = format
  end

  options[:apikey] = nil
  key_text = 'Your Google API key and referrer URL (overrides credentials file)'
  opts.on( '-k KEY:URL', '--key KEY:URL', key_text) do |key|
    options[:apikey] = key
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

api_url = 'http://ajax.googleapis.com/ajax/services/search/web'
apikey = options[:apikey]
apikey ||= read_credentials(options[:keypath])
(apikey, goog_key, referrer) = */^([^:]*):(.*?)$/.match(apikey)
exit "Couldn't get auth data" if apikey.nil?

ARGV.each do |keyword|
  keyword = keyword.gsub(' ','+')
  uri = URI.parse(api_url+'?v=1.0&q='+keyword+'&key='+goog_key)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  request.initialize_http_header({'Referrer' => referrer})
  response = JSON.parse(http.request(request).body)
  link = response['responseData']['results'][0]['url']
  title = response['responseData']['results'][0]['title'].gsub(/<\/?[^>]*>/,'')
  
  case options[:format]
  when 'url'
    puts link
  when 'html'
    puts '<a href="'+link+'">'+title+'</a>'
  when 'markdown'
    puts '['+title+']('+link+')'
  else
    puts 'Unrecognized output format.'
  end
end

