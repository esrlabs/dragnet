Requirements
============

This section should list all the requirements of the project. Normally they
are generated dynamically out of DIM_'s requirements in the ``req`` directory.

If you are seeing this page it means that the requirements haven't been
generated yet. To generate the requirements run the following command:

.. code-block:: none

   bundler exec dim_to_rst req/config.yaml documentation/source/requirements

And then generate the Sphinx documentation again.

.. _DIM: https://esrlabs.github.io/dox/dim/
