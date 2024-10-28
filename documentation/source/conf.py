# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'Dragnet'
copyright = '2023, ESR Labs GmbH'
author = 'ESR Labs GmbH'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = []

templates_path = ['_templates']
exclude_patterns = []



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_material'

html_theme_options = {
  # Set the color and the accent color
  'color_primary': 'green',
  'color_accent': 'light-green',
  'globaltoc_depth': 3
}

html_sidebars = {
   '**': ['globaltoc.html', 'localtoc.html', 'relations.html', 'sourcelink.html', 'searchbox.html']
}

