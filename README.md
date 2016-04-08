# Bundle
## Create the bundle
Creating the bundle is simple. Just run `rake bundle:build` to compile and build the package of ruby with `fastlane` (and `cocoapods` for dependency's sake).

## Using the bundle
In terminal, call `path/to/destroot/fastlane` followed by a normal call to any `fastlane` action or lane.

### Background
This is being build using the same method by which [CocoaPods-app](https://github.com/CocoaPods/CocoaPods-app) is building their bundled ruby. But the process has been pared down to fit our needs.

Some of the code might still contain traces of CocoaPods stuff, and defintely, the way that the `Rakefile` has been broken up could use some work.