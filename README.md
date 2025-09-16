# Dragnet

A gem to verify, validate and analyze MTR (Manual Test Record) files.

Provides a command line tool to perform different types of validations
on MTR files. These files are YAML files that contain information about
the performed test and the revision (commit) for which the test was
performed.

## Why and how?

When testing software you strive to automate as much as you can. However not
everything can be tested with automated tests. Sometimes there is no way to
automate the test, in other cases the effort required to automate the test
vastly exceeds the benefits, or the automated test has a very narrow scope.

In these cases manual tests are a good alternative. But, how do you know when
you need to execute manual tests again? Do you execute them for every release?
That is certainly possible but probably not very efficient. This is where
Dragnet can help.

This is how it works:

1. You create a Manual Test Record (MTR). In it you describe what needs to be
   tested and how.
2. You list the source files that are involved in the feature the MTR refers to.
   (You can list individual files or use glob patterns).
3. You state the SHA1 of the revision you used to perform your test last time.

   *Whenever there are changes to these files Dragnet will detect them and*
   *remind you that the manual test needs to be performed again.*

4. You perform the manual test again and update the SHA1 in the MTR.

> 💡 Dragnet finishes with specific exit codes allowing you to integrate it in
>    your CI pipelines.

## Dragnet needs very little to work

Dragnet only needs Ruby and Git to work. Git is probably already part of your
toolchain and Ruby is a very flexible language. You can install it easily in
any platform or use one of the official Docker images.

## Requirements

* Ruby >= 3.1.0 (MRI)
* Bundler >= 2.4.0
* Git >= 2.0.0

## Setup

Clone the repository and install the dependencies by running:

```shell
bundle install
```

## Running Tests

You can run the tests just by executing RSpec.

```shell
bundle exec rspec
```

To generate a Coverage report:

```shell
export COVERAGE=true
rspec
```

*The coverage report will be written to the `/coverage` path*

## Generating Documentation

```shell
bundle exec yard
```

*The documentation will be generated in the `/doc` path*

## Contributing

* This project uses [Semantic Versioning](https://semver.org/)
* This project uses a `CHANGELOG.md` file to keep track of the changes.

1. Add your feature.
2. While editing your code keep an eye out for Rubocop and Reek suggestions
   try to keep both linters happy. 😉
3. Write unit and integration *(desirably but not required)* tests for it.
4. Run the tests with the coverage report generation enabled (Check the *Running
   Tests section)*.
5. Make sure your Unit Test coverage is at least 90%
6. Run the `yard` command to generate documentation and make sure your
   documentation coverage is 100% (everything should be documented)
7. Add your features to the `CHANGELOG.md` file under the *Unreleased* section.
   (Check the `CHANGELOG.md`) file for info on how to properly add the changes
   there.
8. Push your changes for code review

### Releases

After your changes have been reviewed, approved and merged to master you need to
create a Release Pull Request

1. Decide which type of version increase is the right one for the changes listed
   in the *Unreleased* section of the `CHANGELOG.md` file. (Not only your
   changes but all the changes listed there). Use the criteria outlined in the
   [Semantic Versioning](https://semver.org/) documentation.
2. Increase the version accordingly in the `lib/dragnet/version.rb` file.
3. Create a new section in the `CHANGELOG.md` file for the version and move
   the changes on the *Unreleased* section there.
4. Create a new Pull Request for the release. Make sure to follow the following
   convention for the commit message.

   ```
   [RELEASE] Version x.y.z
   ```
