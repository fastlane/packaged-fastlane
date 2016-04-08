require 'net/https'
response = Net::HTTP.get URI.parse('https://itunesconnect.apple.com/itc/static-resources/controllers/login_cntrl.js')