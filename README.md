# packaged-fastlane
## Create the package 🚀
Creating the bundle is simple. Just run `rake bundle:standalone` to compile and build the package of ruby with `fastlane`. 

This job queries RubyGems to get the most recent version that is available and builds that version of `fastlane`. By running `rake --tasks` you should also be able to predict what version will be built as that will also make the call to fetch the most recent version from RubyGems.

### Cleanup 🚿
Run tasks in the `bundle:clean` namespace to clean up after yourself if you'd like.

## Using the package 📦
In a terminal, call `path/to/bundle-x.x.x/fastlane` followed by a normal call to any `fastlane` action, lane, or tool (i.e. snapshot, gym, etc.).

### Background 🍫
This project is a heavily modified fork of [CocoaPods-app](https://github.com/CocoaPods/CocoaPods-app). The [CocoPods team](https://cocoapods.org/about#team) deserves many thanks for inspiration and assistance!