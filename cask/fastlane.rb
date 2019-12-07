cask 'fastlane' do
  version '2.0.0'
  sha256 'e89bf6d1270f4c9455a523c0dafae3cfe2a704e8e9953390dcdef9852f64b4f7'

  url "https://fastlane.tools/packaged-fastlane-#{version}.zip"
  name 'fastlane'
  homepage 'https://fastlane.tools/'

  installer script: {
                      executable: "#{staged_path}/install",
                      args:       ['-p', '-b', '-y'],
                    }

  uninstall script: {
                      executable: "#{staged_path}/uninstall",
                      args:       ['-y'],
                    }
end
