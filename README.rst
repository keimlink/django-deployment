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

* `Apache <https://httpd.apache.org/>`_ and `mod_wsgi <http://www.modwsgi.org/>`_ for Python 3
* `curl <http://curl.haxx.se/>`_
* `gettext <https://www.gnu.org/software/gettext/>`_
* `Git <https://git-scm.com/>`_
* `memcached <http://memcached.org/>`_ and `python-memcached <http://www.tummy.com/software/python-memcached/>`_
* `nano <http://www.nano-editor.org/>`_
* `Node.js <https://nodejs.org/en/>`_ and `npm <https://www.npmjs.com/>`_
* `Python 3.4 <https://www.python.org/>`_
* `PostgreSQL <http://www.postgresql.org/>`_ and `psycopg2 <http://initd.org/psycopg/>`_
* `SQLite <https://www.sqlite.org/>`_
* `tree <http://mama.indstate.edu/users/ice/tree/>`_
* `Vim <http://www.vim.org/>`_
* `wkhtmltopdf <http://wkhtmltopdf.org/>`_
* Dependencies to build `lxml <https://github.com/lxml/lxml>`_ and `pillow <https://python-pillow.github.io/>`_ Python packages

To create the virtual machine you have to `download
<https://www.vagrantup.com/downloads>`_ and install Vagrant at first. Vagrant
1.8 has successfully been tested with this virtual machine.

You also have to install
`VirtualBox 5.0 <https://www.virtualbox.org/wiki/Download_Old_Builds_5_0>`_.

Then you need to set the path to the Django project you want to deploy. You do
this by exporting the environment variable ``DJANGO_SOURCE``:

::

    $ export DJANGO_SOURCE='../django-workshop/projects/cookbook-project'

.. note::

    If you are on Windows please use the full path to the Django project. Also
    don't use quotes:

    ::

        > set DJANGO_SOURCE=C:\Users\<username>\django-workshop\projects\cookbook-project

After that simply start the virtual machine using:

::

    $ vagrant up

Connecting to the virtual machine
=================================

Once the virtual machine has been created and provisioned you can connect to it
using Vagrant`s ``ssh`` command:

::

    $ vagrant ssh
    ----------------------------------------------------------------
      Debian GNU/Linux 8.6 (jessie)               built 2016-09-28
    ----------------------------------------------------------------
    (venv)vagrant@vagrant:~$

The prompt is prefixed with ``(venv)`` which is the name of the virtualenv that
has automatically been activated for you on login.

Changing the location where Apache searches the WSGI config
===========================================================

If the directory where your ``wsgi.py`` is located is not named ``cookbook``
you need to update the Apache configuration. Otherwise you can skip this step.
To do this run the following command, where you should replace ``myproject`` at
the end with the name of the directory where your ``wsgi.py`` file is located:

::

    $ sudo salt-call state.sls apache pillar='{"project": {"django-config": "myproject"}}'

There will be a lot of output, important is the end which should look like this:

::

    local:
    ----------
              ID: apache2
        Function: pkg.installed
          Result: True
         Comment: Package apache2 is already installed
         Started: 23:30:25.489454
        Duration: 632.087 ms
         Changes:
    ----------
              ID: /etc/apache2/conf-available/wsgi.conf
        Function: file.managed
          Result: True
         Comment: File /etc/apache2/conf-available/wsgi.conf is in the correct state
         Started: 23:30:26.127559
        Duration: 15.482 ms
         Changes:
    ----------
              ID: /etc/apache2/sites-available/django.conf
        Function: file.managed
          Result: True
         Comment: File /etc/apache2/sites-available/django.conf updated
         Started: 23:30:26.143476
        Duration: 15.175 ms
         Changes:
                  ----------
                  diff:
                      ---
                      +++
                      @@ -32,9 +32,9 @@
                           # WSGI
                           WSGIDaemonProcess django.example.com python-path=/src:/home/vagrant/venv/lib/python3.4/site-packages processes=2 threads=15 display-name=%{GROUP}
                           WSGIProcessGroup django.example.com
                      -    WSGIScriptAlias / /src/cookbook/wsgi.py
                      +    WSGIScriptAlias / /src/myproject/wsgi.py

                      -    <Directory /src/cookbook>
                      +    <Directory /src/myproject>
                               <Files wsgi.py>
                                   Require all granted
                               </Files>
    ----------
              ID: apache2
        Function: service.running
          Result: True
         Comment: Service restarted
         Started: 23:30:26.319967
        Duration: 1445.602 ms
         Changes:
                  ----------
                  apache2:
                      True
    ----------
              ID: Enable headers module
        Function: apache_module.enable
            Name: headers
          Result: True
         Comment: headers already enabled.
         Started: 23:30:27.767086
        Duration: 0.748 ms
         Changes:
    ----------
              ID: libapache2-mod-wsgi
        Function: pkg.installed
          Result: True
         Comment: Package libapache2-mod-wsgi is already installed
         Started: 23:30:27.768049
        Duration: 2.415 ms
         Changes:
    ----------
              ID: /etc/apache2/conf-enabled/wsgi.conf
        Function: file.symlink
          Result: True
         Comment: Symlink /etc/apache2/conf-enabled/wsgi.conf is present and owned by root:root
         Started: 23:30:27.770629
        Duration: 4.712 ms
         Changes:
    ----------
              ID: /etc/apache2/sites-enabled/000-default.conf
        Function: file.symlink
          Result: True
         Comment: Symlink /etc/apache2/sites-enabled/000-default.conf is present and owned by root:root
         Started: 23:30:27.775835
        Duration: 1.519 ms
         Changes:

    Summary for local
    ------------
    Succeeded: 8 (changed=2)
    Failed:    0
    ------------
    Total states run:     8
    Total run time:   2.118 s

If ``Failed`` has a value different from ``0``, check if you have made any
typos. Also take a close look at the error message(s). They usually contain a
hint that helps you to find out the reason for the error.

Testing PostgreSQL
==================

After that you can connect to PostgreSQL. Use the password ``django`` to
authenticate:

::

    $ psql -h localhost -U django django
    Password for user django:
    psql (9.4.5)
    SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
    Type "help" for help.

    django=> \l
                                       List of databases
        Name     |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
    -------------+----------+----------+-------------+-------------+-----------------------
     django      | django   | UTF8     | en_US.UTF8  | en_US.UTF8  |
     news        | django   | UTF8     | en_US.UTF8  | en_US.UTF8  |
     nobelprizes | django   | UTF8     | en_US.UTF8  | en_US.UTF8  |
     postgres    | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
     template0   | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
                 |          |          |             |             | postgres=CTc/postgres
     template1   | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
                 |          |          |             |             | postgres=CTc/postgres
    (6 rows)

The ``django`` PostgreSQL user has access to three databases:

* ``django``
* ``news``
* ``nobelprizes``

Configuring your Django project
===============================

Now configure your Django project to use this database connection for all three
databases by editing ``local_settings.py`` as shown below. Also, don't forget
to add the other settings ``DEBUG``, ``ALLOWED_HOSTS`` and ``MEDIA_ROOT``.

The settings at the end of the file are security-related. They enable a few
basic security settings. The setting ``SILENCED_SYSTEM_CHECKS`` disables SSL-
related checks as we're not using SSL for this deployment.

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
            'NAME': 'nobelprizes',
            'USER': 'django',
            'PASSWORD': 'django',
            'CONN_MAX_AGE': 600,
        },
    }

    WKHTMLTOPDF_CMD = 'wkhtmltopdf'

    # Security

    CSRF_COOKIE_HTTPONLY = True

    SECURE_BROWSER_XSS_FILTER = True

    SECURE_CONTENT_TYPE_NOSNIFF = True

    X_FRAME_OPTIONS = 'DENY'

    SILENCED_SYSTEM_CHECKS = [
        'security.W004',
        'security.W008',
        'security.W012',
        'security.W016'
    ]

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

    If you don't have a ``requirements.txt`` file, create one in your
    development environment using:

    ::

        $ pip freeze > requirements.txt

Run the database migrations:

::

    $ ./manage.py migrate
    $ ./manage.py migrate --database=newsdb

Now run the deployment checks (no security issues should be identified):

::

    $ ./manage.py check --deploy

Create a new superuser:

::

    $ ./manage.py createsuperuser

Load some fixtures for the ``recipes`` app:

::

    $ ./manage.py loaddata recipes initial_data

.. note::

    If you don't have any fixtures you can also manually create a few recipes
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

* ``/etc/apache2/conf-available/wsgi.conf``
* ``/etc/apache2/sites-available/django.conf``
* ``/etc/postgresql/9.4/main/pg_hba.conf``

Troubleshooting
===============

If the URL http://127.0.0.1:8000 does not work, check if Vagrant has
auto-corrected the port forwarding for Apache to a different port. Use
Vagrant's ``port`` command to display the forwarded port. Example:

::

    $ vagrant port --guest 80
    8001

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

Code of Conduct
===============

Everyone interacting in the django-deployment project's codebases, issue
trackers, chat rooms and mailing lists is expected to follow the
`PyPA Code of Conduct <https://www.pypa.io/en/latest/code-of-conduct/>`_.
