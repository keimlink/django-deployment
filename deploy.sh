#!/bin/bash
cd
. venv/bin/activate
cd /src
pip install -r requirements.txt
./manage.py migrate
./manage.py migrate --database=newsdb
./manage.py createsuperuser --username admin --email admin@example.com
./manage.py loaddata recipes initial_data
./manage.py collectstatic -v0 --noinput
cp -R media /home/vagrant
sudo chown -R www-data: /home/vagrant/media
sudo service apache2 stop
sudo service apache2 start
