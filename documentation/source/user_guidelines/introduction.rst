User guidelines
===============

Here is a quick user introduction to Dragnet.

Requirements
------------

**Ruby 3.1.0 or greater**:
  Recommended Ruby (MRI) < 3.0

**RubyGems 3.0.0 or greater**:
  Normally installed by default with Ruby.

**Git 2.0.0 or greater**:
  Must be installed in the system and the ``git`` executable should be in the
  ``PATH``.

**unix-like operating system**:
  The tool can run in all systems (provided that the Ruby interpreter is
  available) but to avoid issues with paths and file names a \*nix (ex. Linux,
  Macintosh, BSD, etc) operating system is recommended.

Installation
------------

Dragnet is a Ruby Gem. After installing the gem
you can use the CLI to execute the tool.

To install dragnet tool::

  gem install dragnet

Needed configuration
--------------------

Dragnet needs a configuration to run, the configuration has to contain the path(s) where the MTRs are located.

Example of configuration file content:

.. code-block:: yaml

   # .dragnet.yaml

   glob_patterns:
       - manual/*.yaml

The MTR files have to contain the information regarding each specific MTR:

.. list-table:: MTR Attributes
   :widths: 10 30 35 50 20
   :header-rows: 1

   * - #
     - Parameter
     - Key
     - Value
     - Required
   * - 1
     - ID
     - ``id``
     - The ID of the MTR
     - Yes
   * - 2
     - Result
     - ``result``
     - The result of the Manual Test.
     - Yes
   * - 3
     - SHA1
     - ``sha1``
     - The SHA1 of the commit in which the Manual Test was performed.
     - Yes
   * - 4
     - Name
     - ``name``
     - The name of the person who performed the Manual Test.
     -
   * - 5
     - Description
     - ``description``
     - The description of the Manual Test, normally which actions were performed and what it was mean to test.
     -
   * - 6
     - Files
     - ``files``
     - The files involved in the MTR, these are the files which will be checked for changes when evaluating the
       validity of the MTR.
     - Either ``files`` or ``repos`` should be present, not both.
   * - 7
     - Repositories
     - ``repos``
     - An array of Hashes with the information about the repositories that are involved in the MTR, these
       repositories will be checked for changes during the evaluation of the MTR.
     - Either ``files`` or ``repos`` should be present, not both.
   * - 8
     - Review Status
     - ``review_status``
     - The review status of the MTR. (Normally changed when someone other than the tester verifies the result
       of the Manual Test)
     -
   * - 9
     - Review comments
     - ``review_comments``
     - The comments left by the person who performed the review of the Manual Test.
     -
   * - 10
     - Findings
     - ``findings``
     - The findings that the reviewer collected during the review process (if any).
     -
   * - 11
     - Test method
     - ``test_method``
     - The method(s) used to carry out the test.
     -
   * - 12
     - Test case derivation mathod
     - ``tc_derivation_method``
     - The method(s) used to derive the test case, note either files or repos should be present, not both.
     -

The **repo** array structure:

.. list-table:: 
   :widths: 5 35 15 45 20
   :header-rows: 1

   * - #
     - Parameter
     - Key
     - Value
     - Required
   * - 1
     - Path
     - ``path``
     - The path where the repository is stored.
     - Yes
   * - 2
     - SHA1
     - ``sha1``
     - The SHA1 the repository had when the MTR was created.
     - Yes
   * - 3
     - files
     - ``files``
     - The file or array of files covered by the MTR.
     -


Dragnet tool usage
------------------

To use Dragnet use the CLI to launch the tool, the tool accepts the following arguments:

**Commands**

dragnet --version
  Prints the current version of the Gem

dragnet --help [COMMAND]
  Describes available commands or one specific **COMMAND**

dragnet check [OPTIONS] [PATH]
   Executes the verify procedure on the given **PATH**. If **PATH** is not
   present, this defaults to the value of the ``path`` key in the configuration
   file or the current working directory if the later is also missing.

**Options**

--export      If given, the results of the verification procedure will be exported to the given file. The format
              of the export will be deducted from the given file's name. (HTML and JSON formats are currently supported)
              The switch can be used multiple times to produce multiple output files.
--multi-repo  Enables the multi-repo compatibility mode. This prevents Dragnet from assuming that [PATH] refers
              to a Git repository allowing it to run even if that is not the case.

              Using this option will cause Dragnet to raise an error if it finds a MTR which doesn't have a ``repos``
              attribute.
--quiet       Suppresses the log messages (except errors).

**Example of usage:**

``dragnet check --export dragnet.html .``

**Output:**

Dragnet will produce the following output:

* A log of the executed operations and abnormal conditions. The logs will always
  go to the Standard Output. (Logs can be suppressed with the ``--quiet``
  command line switch).
* When the ``--export`` command line switch is used, Dragnet exports the results
  of the execution to the given format.
* Dragnet's process will finish with a particular exit code, which reflects the
  result of the execution. The list of :ref:`Possible exit codes <exit-codes>`
  can be found here.
