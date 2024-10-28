Contributing
============

Reporting Bugs and Issues
-------------------------

If you find issues with the tool you can report them on `Dragnet's Issue Tracker`_:

Follow these general guidelines

1. Add a descriptive title for your issue.
2. Add a detailed description of your issue:

   a. What version of ``Dragnet`` were you using?
   b. What steps would reproduce the issue?
   c. What was the expected behavior and what did you see instead?
   d. Attach any evidence you have for the issue (screenshots, log traces, etc.).
   e. Provide any environment configuration that might be needed to reproduce
      the issue.

      **NOTE:** Do not include credentials or any other sensitive information
      in your bug report.

Contributing new code to the codebase
-------------------------------------

If you want to contribute new features to the tool or if you want to improve one
of the existing features please follow these steps to make contributions to the
codebase:

1. Clone `Dragnet's Repository`_:

   ``git clone "git@github.com:esrlabs/dragnet.git"``

2. Add/modify the requirements for your feature. ``dragnet``'s
   requirements are stored in DIM_ files in the ``req`` directory.
3. Develop your feature following
   :doc:`Dragnet's Coding Style <../development_guidelines/coding_style>`
4. Add unit and integration tests for your feature and link the requirements
   you added/modified in Step 2 to your tests. Follow the `Test documentation`_
   guide.
5. Document your changes in the ``CHANGELOG.md`` file. Follow the schema
   described in the `Keep a Changelog`_ page. Mark backwards incompatible
   changes with a ``!`` at the beginning.
6. Commit your changes. Follow
   `ESR Labs's guidelines for writing commit messages`_. Reference a the issue
   number (if there is one).
7. Push your changes for review, create a Pull Request.
8. Take care of any linter issues raised by the linters.
9. Once your changes are approved by peer review and verified by the CI
   infrastructure your changes will be merged to the ``master`` branch.

Releasing Changes
-----------------

To make merged changes available for the projects it is necessary to release a
new version of the gem. To do so:

1. Open the ``CHANGELOG.md`` file.
2. Check all the changes in the ``Unreleased`` section. Decide what type of
   version increment should be made. For this use the `Semantic Versioning`_
   guidelines.
3. Under the ``Unreleased`` section add a new header for the version you want to
   release and the date when the changes will be released.
4. Open the ``lib/dragnet/version.rb`` file and adjust the version number
   accordingly.
5. Commit your changes. The commit message for release commits should follow
   this pattern:

   ``[RELEASE] Version X.Y.Z``

6. Create a Pull Request for the release.
7. Get your changes reviewed and approved by your peers.
8. The changes should **ONLY** be merged on the date you specified in the
   ``CHANGELOG.md`` file. If the changes weren't approved on time update the
   date and push the changes for review again.

.. _`Dragnet's Issue Tracker`: https://github.com/esrlabs/dragnet/issues
.. _`Dragnet's Repository`: https://github.com/esrlabs/dragnet
.. _DIM: https://docs.int.esrlabs.com/dim/index.html
.. _`Test documentation`: https://docs.int.esrlabs.com/guidelines/general/testing/test_documentation.html
.. _`Keep a Changelog`: https://keepachangelog.com/en/1.0.0/
.. _`ESR Labs's guidelines for writing commit messages`: https://docs.int.esrlabs.com/guidelines/general/scm/commit_message.html
.. _`Semantic Versioning`: https://semver.org/spec/v2.0.0.html
