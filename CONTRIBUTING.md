# Contributing to CCMenu

First off, thank you for taking the time to contribute to CCMenu!

The following is a set of guidelines for contributing to CCMenu. These are just guidelines, not rules. Use your best judgment and feel free to propose changes to this document in a pull request.

This project adheres to the [Contributor Covenant 1.2](http://contributor-covenant.org/version/1/2/0). By participating, you are expected to uphold this code. 


## Submitting issues

* If you have encountered an issue or you want to suggest an enhancement, have a look at the [existing issues](https://github.com/erikdoe/ccmenu/issues?q=is%3Aissue) to see if a similar one has already been submitted.

* When you submit an issue, please provide as much information as possible. The easier it is to understand and reproduce the problem, the more likely it is that we can provide a fix.

* Include the version of CCMenu you are using, especially if you didn't download it from the App Store.


## Pull requests

* Create all pull requests from `master`. Do not include other pull requests that have not been merged yet.

* Limit each pull request to one feature. If you have made several changes, please submit multiple pull requests. Do not include seemingly trival changes, e.g. upgrading the Xcode version, in a pull request for a feature or bugfix.

* If you add a new feature, provide corresponding tests. If you have to remove an existing test because it fails in the presence of newly introduced code, please explain the rationale in the pull request.

* Once you have created the pull request, an automated build is kicked off on [Travis CI](https://travis-ci.org/erikdoe/ccmenu/pull_requests). Please verify after a few minutes that the build on the server succeeded. **Pull requests with failing builds are ignored and will be closed within a few weeks if they are not fixed.**
