Inputs and Outputs
==================

This section provides the user a description of the inputs and outputs to and from the Dragnet Gem.

Inputs
------

1. **CLI Arguments** that are passed to the Dragnet gem via CLI during initializzation:

   1. Dragnet configuration and execution folder
   2. Multi-repo enable option

2. **Dragnet configuration files**

   1. configuration file ``.dragnet.yaml`` is expected to be in the execution folder but an alternative path can be
   given via the CLI. It contains the configuration for dragnet, for example the glob patterns used to locate
   MTR files, among other things.

Outputs
-------

1. **CLI Logs** of the executed commands
2. **JSON/HTMl report export** of the check results on user request
3. **Exit Code**

.. _`exit-codes`:

Possible Exit Codes
+++++++++++++++++++

+-----------+-----------------------------------------------------------------------------+
| Exit Code | Meaning                                                                     |
+===========+=============================================================================+
| 0         | Success: MTR files were loaded successfully and their verification passed.  |
+-----------+-----------------------------------------------------------------------------+
| **Unrecoverable (the execution will be aborted, export can be incomplete)**             |
+-----------+-----------------------------------------------------------------------------+
| 2         | The given path (CLI argument) or the glob patterns in the                   |
|           | configuration file are invalid or malformed                                 |
+-----------+-----------------------------------------------------------------------------+
| 3         | Dragnet couldn't find any MTR files using the given glob patterns           |
+-----------+-----------------------------------------------------------------------------+
| 4         | Dragnet was unable to open the specified path (or the current working       |
|           | directory, if no path was given) as a Git repository.                       |
+-----------+-----------------------------------------------------------------------------+
| 5         | Dragnet was unable to write to one or more of the files specified to export |
|           | the data after the analysis (for example the HTML report).                  |
+-----------+-----------------------------------------------------------------------------+
| 6         | Signals that a git operation was attempted on a repository with an          |
|           | incompatible type. This happens, for example, if the ``--multi-repo``       |
|           | command line switch is given but the repository being checked is not a      |
|           | multi-repository (managed with `git-repo`_), or the other way around.       |
+-----------+-----------------------------------------------------------------------------+
| **Recoverable (the execution will finish, data will be exported)**                      |
+-----------+-----------------------------------------------------------------------------+
| 16        | Signals that Dragnet was unable to load one or more of the MTR files        |
|           | because of a format error, for example: a YAML syntax error, missing        |
|           | attributes, incompatible types, etc.                                        |
+-----------+-----------------------------------------------------------------------------+
| 32        | Signals that one or more of the MTRs failed (``result`` is ``failed``) or   |
|           | were skipped (changes were detected in the repository)                      |
+-----------+-----------------------------------------------------------------------------+
| 48        | (Bitwise OR of 16 and 32) Signals that both the above conditions happened.  |
+-----------+-----------------------------------------------------------------------------+

.. _`git-repo`: https://gerrit.googlesource.com/git-repo
