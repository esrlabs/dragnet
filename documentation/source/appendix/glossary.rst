Glossary
========

Manual Test:
  A software test that is executed manually, either because it cannot be easily
  automated or because it needs physical probing (for example, with an
  oscilloscope). Manual tests are performed against a specific revision of the
  software, normally defined by the SHA1 of the corresponding revision.

MTR - Manual Test Record:
  A file that records the execution of a manual test. It needs to have at the
  very least the ID of the requirement it is testing, the SHA1 of the revision
  used when the test was run and a result: either passed or failed.

  MTRs are stored in YAML format.

Requirement:
  One of the requirements defined for the software being tested. Normally
  (although not necessarily) managed with DIM_. Each requirement has a unique
  ID, which is also used as ID for the MTR.

Repository:
  Refers to a source code repository managed with Git_.

SHA1:
  Is the name of a hashing algorithm. In Dragnet's context it refers to the ID
  of an individual software revision. Git generates a SHA1 Hash for every change
  (commit_) made to a source code repository under its control.

Glob Pattern:
  Refers to a particular set of symbols used to reference multiple files in a
  file system. In dragnet this refers to:

  * The patterns used to locate MTR files inside the repository.
  * The patterns used to reference files inside an MTR.

  Form more information check the :doc:`../user_guidelines/introduction`.

Exploration
  In this step of the process Dragnet searches for MTR files.

Validation
  In this step of the process Dragnet validates that the MTR files found during
  the exploration phase are valid. This means: No syntax errors, all required
  attributes are present and have valid values.

Verification
  Here Dragnet actually checks the MTRs against the repository. Dragnet checks
  if there have been any changes to the repository between the revision
  annotated in the MTR and the current commit.

Exporting
  Here Dragnet exports the results of the above steps to the specified format.
  The exported data varies with the selected format.

.. _DIM: https://docs.int.esrlabs.com/dim/index.html
.. _Git: https://git-scm.com/
.. _commit: https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository#_committing_changes
