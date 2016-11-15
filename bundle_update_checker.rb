require 'net/http'
require 'json'

uri = URI('https://kits-crashlytics-com.s3.amazonaws.com/fastlane/standalone/version.json')
json_string = Net::HTTP.get(uri)
json = JSON.parse(json_string)
available_bundle_version = json["bundle_version"]

path_to_version = File.expand_path(File.join(File.dirname(__FILE__), 'VERSION'))
current_bundle_version = File.foreach(path_to_version).first.chomp.to_f

if available_bundle_version > current_bundle_version
  puts "UPDATE FASTLANE"
else
  puts "FASTLANE UP TO DATE"
end
