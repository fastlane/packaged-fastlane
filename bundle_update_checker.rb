require 'net/http'
require 'json'

begin
  url = URI.parse('https://kits-crashlytics-com.s3.amazonaws.com/fastlane/standalone/version.json')
  # Work around ruby defect, where HTTP#get_response and HTTP#post_form
  # don't use ENV proxy settings
  # https://bugs.ruby-lang.org/issues/12724
  http_conn = Net::HTTP.new(url.host, url.port)
  http_conn.use_ssl = true
  http_conn.read_timeout = 5
  http_conn.open_timeout = 5
  http_conn.ssl_timeout = 5

  resp = http_conn.request_get(url.path)

  version_file = File.expand_path(File.join(File.dirname(__FILE__), 'VERSION'))
  unless File.exist?(version_file)
    raise "Version file not found `#{version_file}`"
  end
  json_string = resp.body
  json = JSON.parse(json_string)
  available_bundle_version = json['bundle_version']

  version_string = File.open(version_file) { |file| file.each_line.first }
  current_bundle_version = version_string.chomp.to_f

  if available_bundle_version > current_bundle_version
    puts 'fastlane update available'
    if ENV['FASTLANE_INSTALLED_VIA_HOMEBREW'] == 'true'
      puts 'Please run `brew update && brew cask reinstall fastlane`'
    else
      puts 'Please update fastlane by downloading an updated bundle from'
      puts 'https://download.fastlane.tools'
    end
  end
rescue => ex
  puts "fastlane could not check for updates error: #{ex.message}"
end
