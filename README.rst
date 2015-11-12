*****************
Django Deployment
*****************

A virtual machine to deploy the free `Django Workshop <http://www.django-
workshop.de/>`_ tutorial.

Creating a virtual machine using Vagrant
========================================

The repository contains a configuration for a virtual machine. This
configuration will install all necessary software during setup. It's a `Debian
<http://www.debian.org/>`_ system. The provisioning will done using `Salt
<http://www.saltstack.com/community/>`_.

To create the virtual machine you have to `download
<http://www.vagrantup.com/downloads>`_ and install Vagrant at first.

Then you need to set the path to the Django project you want to deploy. You do
this by exporting the environment variable ``DJANGO_SOURCE``:

::

    $ export DJANGO_SOURCE='../django-workshop/projects/cookbook-project'

After that simply start the virtual machine using:

::

    $ vagrant up

Once the virtual machine has been created and provisioned you can connect to it
using Vagrant`s ``ssh`` command:

::

    $ vagrant ssh

After that you can connect to PostgreSQL. Use the password "django" to
authenticate:

::

     $ psql -h localhost -U django django

Now configure your Django project to use this database connection.

Then configure your ``local_settings.py`` to use the PostgreSQL databases. Also
don't forget to set ``DEBUG = False`` and to define ``ALLOWED_HOSTS``:

::

    DEBUG = False

    ALLOWED_HOSTS = ['127.0.0.1']

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

Finally you have to run the following commands to set up the Django project:

::

    . venv/bin/activate
    cd /src
    pip install -r requirements.txt
    ./manage.py migrate
    ./manage.py migrate --database=newsdb
    ./manage.py createsuperuser
    ./manage.py loaddata recipes initial_data
    sudo service apache2 reload

Now open http://127.0.0.1:8000 and visit your Django project!
