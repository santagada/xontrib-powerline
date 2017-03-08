Xontrib Powerline
=================

Powerline for Xonsh shell.

.. image:: https://github.com/santagada/xontrib-powerline/raw/master/screenshot.png

Install
-------

To install this xontrib first download and install the python package:

.. code:: bash

    pip3 install xontrib-powerline

And them load it on your ``.xonshrc``

.. code:: bash

    xontrib load powerline

Configuration
-------------

There are two variables that can be set, ``PL_PROMPT`` for the right prompt and ``PL_TOOLBAR`` for the bottom toolbar.
They contain a list of sections that can be used separated by ``>``. The value ``!`` means not to use that prompt.

Examples:

.. code:: python

    $PL_TOOLBAR = 'who>virtualenv>branch>cwd>full_proc'
    $PL_TOOLBAR = '!'  # for no toolbar

To see all available sections type ``pl_available_sections``, and to commit changes to your prompt execute ``pl_build_prompt``.

More Info
---------

read more on the `xontrib docs`_ and if you want to create your own on
the `xontrib tutorial`_

Credits
-------

This package was created by Leonardo Santagada with Cookiecutter_ 
and the `laerus/cookiecutter-xontrib`_ project template.

The font being used on the screenshot is the incredible `3270 font`_ with injected characters from `nerd fonts`_.

.. _`nerd fonts`: https://github.com/ryanoasis/nerd-fonts
.. _`3270 font`: https://github.com/rbanffy/3270font
.. _`xontrib docs`: http://xon.sh/xontribs.html
.. _`xontrib tutorial`: http://xon.sh/tutorial_xontrib.html
.. _Cookiecutter: https://github.com/audreyr/cookiecutter
.. _`laerus/cookiecutter-xontrib`: https://github.com/laerus/cookiecutter-xontrib
