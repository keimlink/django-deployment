*****************
Django Deployment
*****************

A virtual machine to learn how to deploy the free `Django Workshop
<http://www.django-workshop.de/>`_ tutorial.

Creating the virtual machine
============================

The repository contains a configuration for a virtual machine. This
configuration will install all necessary software during setup. It's a `Debian
<https://www.debian.org/>`_ system, the provisioning will done using `Salt
<https://www.saltstack.com/community/>`_.

Salt will install and configure the following software:

* `Apache <https://httpd.apache.org/>`_ and `mod_wsgi <http://www.modwsgi.org/>`_
* `curl <http://curl.haxx.se/>`_
* `gettext <https://www.gnu.org/software/gettext/>`_
* `Git <https://git-scm.com/>`_
* `memcached <http://memcached.org/>`_ and `python-memcached <http://www.tummy.com/software/python-memcached/>`_
* `nano <http://www.nano-editor.org/>`_
* `nfs-common <https://packages.debian.org/jessie/nfs-common>`_
* `Node.js <https://nodejs.org/en/>`_, `npm <https://www.npmjs.com/>`_, `Bower <http://bower.io/>`_ and `gulp.js <http://gulpjs.com/>`_
* `pip <https://pip.pypa.io/>`_
* `PostgreSQL <http://www.postgresql.org/>`_ and `psycopg2 <http://initd.org/psycopg/>`_
* `SQLite <https://www.sqlite.org/>`_
* `tree <http://mama.indstate.edu/users/ice/tree/>`_
* `Vim <http://www.vim.org/>`_
* `virtualenv <https://virtualenv.pypa.io/>`_
* `wkhtmltopdf <http://wkhtmltopdf.org/>`_
* Dependencies to build `lxml <https://github.com/lxml/lxml>`_ and `pillow <https://python-pillow.github.io/>`_ Python packages

To create the virtual machine you have to `download
<https://www.vagrantup.com/downloads>`_ and install Vagrant at first. You will
also need to install a hypervisor like `VirtualBox
<https://www.virtualbox.org/>`_.

Then you need to set the path to the Django project you want to deploy. You do
this by exporting the environment variable ``DJANGO_SOURCE``:

::

    $ export DJANGO_SOURCE='../django-workshop/projects/cookbook-project'

After that simply start the virtual machine using:

::

    $ vagrant up

Connecting to the virtual machine
=================================

Once the virtual machine has been created and provisioned you can connect to it
using Vagrant`s ``ssh`` command:

::

    $ vagrant ssh

Testing PostgreSQL
==================

After that you can connect to PostgreSQL. Use the password ``django`` to
authenticate:

::

     $ psql -h localhost -U django django

The ``django`` PostgreSQL user has access to three databases:

* ``django``
* ``news``
* ``addressbook``

Configuring your Django project
===============================

Now configure your Django project to use this database connection for all three
databases by editing ``local_settings.py``. Also, don't forget to the other
settings ``DEBUG``, ``ALLOWED_HOSTS`` and ``MEDIA_ROOT``:

.. code-block:: python

    DEBUG = False

    ALLOWED_HOSTS = ['127.0.0.1']

    MEDIA_ROOT = '/home/vagrant/media'

    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql_psycopg2',
            'NAME': 'django',
            'USER': 'django',
            'PASSWORD': 'django',
            'CONN_MAX_AGE': 600,
        },
        'newsdb': {
            'ENGINE': 'django.db.backends.postgresql_psycopg2',
            'NAME': 'news',
            'USER': 'django',
            'PASSWORD': 'django',
            'CONN_MAX_AGE': 600,
        },
        'addressdb': {
            'ENGINE': 'django.db.backends.postgresql_psycopg2',
            'NAME': 'addressbook',
            'USER': 'django',
            'PASSWORD': 'django',
            'CONN_MAX_AGE': 600,
        },
    }

.. note::

    Because we are running Apache inside a virtual machine and forwarding the
    port to our host machine ``ALLOWED_HOSTS`` needs just the single value
    ``'127.0.0.1'``. A deployment on a real server would require something like
    ``'example.com'`` or ``'www.example.com'``.

    Also note that it's strongly recommended to set a different ``SECRET_KEY``
    for a production system.

Deploying your Django project
=============================

Finally you have to run the following commands to deploy the Django project.

Activate the virtualenv:

::

    $ . venv/bin/activate

Change into the ``/src`` directory (where Vagrant created a synched folder
pointing at your project files):

::

    $ cd /src

Install all Python packages:

::

    $ pip install -r requirements.txt

.. note::

    psycopg2, the PostgreSQL database adapter for the Python, has already been
    installed into the virtual env.

    If you don't have a ``requirements.txt`` file create one in your
    development environment using:

    ::

        $ pip freeze > requirements.txt

Run the database migrations:

::

    $ ./manage.py migrate
    $ ./manage.py migrate --database=newsdb

Create a new superuser:

::

    $ ./manage.py createsuperuser

Load some fixtures for the ``recipes`` app:

::

    $ ./manage.py loaddata recipes initial_data

.. note::

    If don't have any fixtures you can also manually create a few recipes
    later.

Collect the static files into the directory ``/src/static_root``:

::

    $ ./manage.py collectstatic

Also, you need to copy the directory for media files (uploads) to a different
location. This is necessary so that the user ``www-data``, which is the user
Apache uses, can write uploads to the disk. And unfortunately you can't
transfer ownership of directories in a Vagrant share.

::

    $ cp -R media /home/vagrant

If you don't have a ``media`` directory, just create one in ``/home/vagrant``:

::

    $ mkdir /home/vagrant/media

Then change the owner and group of the ``media`` directory to ``www-data``:

::

    $ sudo chown -R www-data: /home/vagrant/media

Finally restart the Apache web server:

::

    $ sudo service apache2 stop
    $ sudo service apache2 start

Now open http://127.0.0.1:8000 and visit your Django project!

Learning more about the configuration of Apache and PostgreSQL
==============================================================

If you want to understand how Apache and PostgreSQL have been configured to
work with Django, take a look the following files:

* ``/etc/apache2/sites-available/django.conf``
* ``/etc/postgresql/9.4/main/pg_hba.conf``

Troubleshooting
===============

If the URL http://127.0.0.1:8000 does not work, check if Vagrant has
auto-corrected the port forwarding to a different port. Vagrant displays this
information after you executed ``vagrant up``. Example:

::

    ==> default: Forwarding ports...
    default: 80 => 8000 (adapter 1)
    default: 22 => 2222 (adapter 1)

If you don't see anything in the browser or just an error message by Apache,
here are a few things you can try to find out more.

Run the following command to see Apache status information:

::

    $ sudo service apache2 status

Take a look at Apache`s global error log:

::

    $ sudo less /var/log/apache2/error.log

Examine the Apache error log for the virtual host:

::

    $ sudo less /var/log/apache2/django.example.com-error.log

Check if the ``media`` directory has been copied and has the correct
permissions:


::

    $ ls -la /home/vagrant/media
    total 20
    drwxr-xr-x 3 www-data www-data 4096 Nov 16 16:43 .
    drwxr-xr-x 6 vagrant  vagrant  4096 Nov 16 16:52 ..
    drwxr-xr-x 2 www-data www-data 4096 Nov 16 16:55 recipes
