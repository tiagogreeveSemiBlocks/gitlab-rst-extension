.. This file exercises every RST construct GitLab can now render.
   Push it to a project as README.rst (or open docs/index.rst) after
   installing the enhanced renderer.

Test File: Every RST Feature
===========================

:Author: Tiago Greeve
:Date: 2026-11-06
:Status: Renders fully in GitLab

Introduction
------------

Plain paragraphs with *emphasis*, **strong emphasis**, inline literals
like ``gitlab-ctl restart``, and a `default role` here.

Admonitions
----------

.. attention:: Attention - direct the reader quickly.

.. caution:: Caution - possible damage to equipment or data.

.. danger:: Danger - security or data-loss risk.

.. error:: Error - something failed.

.. hint:: Hint - a helpful shortcut.

.. important:: Important - do not skip this.

.. note:: Note - supplementary information.

.. tip:: Tip - a useful trick.

.. warning:: Warning - be careful.

.. admonition:: Generic Admonition

   A generic admonition block with its own title.

Tables
------

Grid table:

+------------+------------+-----------+
| Header 1   | Header 2   | Header 3  |
+============+============+===========+
| cell       | cell       | cell      |
+------------+------------+-----------+
| spanning   | spanning   | cell      |
+------------+------------+-----------+

Simple table:

=====  =====  =======
A      B      A and B
=====  =====  =======
False  False  False
True   False  False
=====  =====  =======

List table:

.. list-table:: List Table
   :header-rows: 1

   * - Col A
     - Col B
   * - 1
     - 2

Code
----

.. code:: python

   def render(text):
       """Render RST to HTML."""
       from docutils.core import publish_parts
       return publish_parts(source=text, writer_name="html5")["body"]

Literal block::

   $ gitlab-ctl restart gitlab-rails

Structural elements
-------------------

.. sidebar:: Sidebar Title

   Sidebars float (or box) supplementary content.

.. topic:: Topic Title

   A topic is an unnumbered, untitled section-like container.

.. rubric:: A Rubric

Field lists, definition lists and option lists
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:Field one: first value
:Field two: second value

Term
    Definition of the term.

-a          Output all
--long ARG  Use ARG, required

Quotes, transitions, footnotes
------------------------------

  An epigraph or block quote.

----

A footnote reference [#f1]_ and a citation reference [CIT2001]_.

.. [#f1] A numbered footnote.
.. [CIT2001] A citation.

Contents
--------

.. contents:: :local:

Conclusion
----------

If admonitions are colored and tables have borders, the enhanced
renderer is working.
