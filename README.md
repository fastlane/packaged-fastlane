# Bundle
## Create the bundle
Creating the bundle is simple. Just run `rake bundle:bundle` to compile and build the package of ruby with `fastlane`. This will create the `.zip` file as well for sending to other people for testing or (if totally necessary) deploying to S3.

This job queries RubyGems to get the most recent version that is available and builds that version of `fastlane`. By running `rake --tasks` you should also be able to predict what version will be built as that will also make the call to fetch the most recent version from RubyGems.

### Cleanup
Run `rake bundle:clean:all` to clean up everything from the bundle you created and start fresh.

### TeamCity
TeamCity runs `rake bundle:ci_bundle` which has the additional task of pushing the newly built bundle to S3 and also bumping the version number in the `version.json` file to reflect the most recent version of the gem.

Currently, there are still issues with adding that second VCS root to the job to trigger the build, so kicking it off manually is necessary and as we've seen since we have shipped, it is not the worst thing in the world that this doesnt get kicked off automatically from `fastlane` pushes.

That being said, the designed behavior is that if this job does run, it will check to see if the `version.json` is behind the version on RubyGems before it will continue to build. If the `version.json` is up to date, the job will finish and no new bundle will be built or uploaded.

## Using the bundle
In terminal, call `path/to/destroot/fastlane` followed by a normal call to any `fastlane` action or lane.

### Background
This is being build using the same method by which [CocoaPods-app](https://github.com/CocoaPods/CocoaPods-app) is building their bundled ruby. But the process has been pared down to fit our needs.

Some of the code might still contain traces of CocoaPods stuff, and defintely, the way that the `Rakefile` has been broken up could use some work.