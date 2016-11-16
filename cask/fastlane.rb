cask 'fastlane' do
  VERSION_NUMBER='1.0'

  version VERSION_NUMBER
  sha256 '7ce7c6f200ca54b33d1bb9a175feb8517d547745a1e01ad08c9137d7d9600133'

  url "https://kits-crashlytics-com.s3.amazonaws.com/fastlane/standalone/bundle-#{VERSION_NUMBER}.zip"
  name 'fastlane'
  homepage 'https://fastlane.tools'

  installer script: "./install",
            args: ['-p', '-u', '-b'],
            sudo: false

  uninstall script: { executable: "./uninstall",
                            args: ['-y'],
                            sudo: false }
end
