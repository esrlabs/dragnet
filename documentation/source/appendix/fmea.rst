FMEA
====

The FMEA is done at the "General" and "Use-Case" level of the library architecture.
The "Use cases" chapter was analyzed over:

* Explore to find MTRs
* Validate the MTRs syntax
* Verify the MTRs status with history
* Export the verifications results

Fault Model
-----------

The following model is based on the “SWA Fault Model” for activity diagrams
currently used for embedded software.

+------------------+----------+----------------------------------------------------------------+
| Element Type     | Error ID | Generic Error Description                                      |
+==================+==========+================================================================+
| **Data storage** | DS1      | Stored data changed before read operation                      |
+------------------+----------+----------------------------------------------------------------+
|                  | DS2      | New data not stored / keeps old data / stuck at specific value |
+------------------+----------+----------------------------------------------------------------+
| **Data flow**    | DF1      | Transferred data changed                                       |
+------------------+----------+----------------------------------------------------------------+
|                  | DF2      | Transferred data lost                                          |
+------------------+----------+----------------------------------------------------------------+
|                  | DF3      | Data stored at / read from wrong location in data store        |
+------------------+----------+----------------------------------------------------------------+
|                  | DF4      | Data transferred to wrong data store                           |
+------------------+----------+----------------------------------------------------------------+
| **Processing**   | PR1      | Calculates wrong results                                       |
+------------------+----------+----------------------------------------------------------------+
|                  | PR2      | Processing is skipped                                          |
+------------------+----------+----------------------------------------------------------------+
|                  | PR3      | Processing too slow / fast                                     |
+------------------+----------+----------------------------------------------------------------+
| **Control flow** | CF1      | Control flow stops                                             |
+------------------+----------+----------------------------------------------------------------+
|                  | CF2      | Control flow proceeds to wrong process                         |
+------------------+----------+----------------------------------------------------------------+

If more than one error is identified for the same element with the same error
ID, a counter is added, e.g. DF1.1, DF1.2, etc.

Generalized Errors
------------------

The following errors are analyzed generically and not on architectural element
level.

.. list-table::
   :widths: 10 20 45 45
   :header-rows: 1

   * - Error ID
     - Affected Elements
     - General Error Description
     - Measures
   * - DF2
     - Data flow from / to shell and internal data storage.
     - Internal buffers data lost
     - Single thread library
   * - PR3
     - Processing
     - Timing issue on slow execution leading to timeouts expiration, low efficiency in execution time
     - Coding style / Code review
        * Reduced cyclomatic complexity
        * Sleep in the code not normally allowed
        * Minimum strictly needed inclusions are used
   * - CF1
     - Control flow
     - Blocking methods without timeout coverage, Ruby VM stuck on non retuning forks leading to execution stuck,
       low efficency in execution time
     - Coding style / Code review
        * Cover blocking calls with timeouts

Explore to find MTRs
--------------------

The analysis for this section was done based on the ``Explore`` part of the :ref:`use cases diagram <use-cases>`
in the use cases session

.. list-table::
   :widths: 12 8 30 25 25
   :header-rows: 1

   * - Element
     - Error ID
     - Specific Error Description
     - Measures
     - References
   * - Explorer
     - DS2 / DF3 / DF4
     - User configuration (``.dragnet.yaml``) is malformed / not supported encoding leading to parsing error or wrong
       initial configuration.
       i.e. the configuration may be generated or transferred leading to loss of integrity.
     - Assumption for the library user on performing integrity check over user configuration before using in the
       library. The integrity has to be granted also in the case the configuration file is generated or given to
       the Library by any script. Code Testing grant coverage over exceptions handling
     -

Validate the MTRs syntax
------------------------

The analysis for this section was done based on the ``Validate`` part of the
:ref:`use cases diagram <use-cases>`  in the use cases session

.. list-table::
   :widths: 10 10 30 25 25
   :header-rows: 1

   * - Element
     - Error ID
     - Specific Error Description
     - Measures
     - References
   * - Validator
     - DS2 / DF3 / DF4
     - MTRs configurations content is malformed / not supported encoding leading to parsing error or wrong
       initial configuration.
       i.e. the configuration may be generated or transferred leading to loss of integrity.
     - Assumption for the library user on performing integrity check over user configuration before using in the
       library. The integrity has to be granted also in the case the configuration file is generated or given to
       the Library by any script. Code Testing grant coverage over exceptions handling
     -

Verify the MTRs status with history
-----------------------------------

The analysis for this section was done based on the ``Verify`` part of the
:ref:`use cases diagram <use-cases>` in the use cases session

.. list-table::
   :widths: 10 10 30 25 25
   :header-rows: 1

   * - Element
     - Error ID
     - Specific Error Description
     - Measures
     - References
   * - Verifier, ChangesVerifier, Repository
     - PR1
     - Library to Git passed parameters wrong / malformed leading to wrong behaviour
     - Code review
     -
   * - Master
     - PR1.1
     - Library fails to handle internal exceptions leading to wrong behaviour
     - Code review, unit / integration testing
     -
   * - Verifier, ChangesVerifier, Repository
     - PR2
     - Git connection loss leading to wrong behaviour
     - Code review over exception coverage
     -
   * - Logger
     - PR1
     - Library to CLI passed data is wrong / malformed leading to wrong behaviour
     - Code review
     -

Export the verifications results
--------------------------------

The analysis for this section was done based on the ``Export`` part of the
:ref:`use cases diagram <use-cases>` in the use cases session

.. list-table::
   :widths: 10 10 30 25 25
   :header-rows: 1

   * - Element
     - Error ID
     - Specific Error Description
     - Measures
     - References
   * - Exporter, HTMLExporter, JSONExporter
     - PR1
     - Library to JSON/HTML export data passed is wrong / malformed leading to wrong behaviour
     - Code review
     -