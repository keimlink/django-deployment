#!/bin/bash
# Bash script to test deployment
cd
echo "Activating virtualenv"
. venv/bin/activate
cd /src
echo "Installing requirements"
pip install -r requirements.txt
echo "Running migrations"
./manage.py migrate
./manage.py migrate --database=newsdb
echo "Running deployment checks"
./manage.py check --deploy
echo "Creating new superuser 'admin'"
./manage.py createsuperuser --username admin --email admin@example.com
echo "Loading initial data"
./manage.py loaddata recipes initial_data
echo "Collecting static files"
./manage.py collectstatic -v0 --noinput
echo "Copying media files"
sudo rm -fr /home/vagrant/media
cp -R media /home/vagrant
sudo chown -R www-data: /home/vagrant/media
echo "Restarting Apache"
sudo service apache2 stop
sudo service apache2 start
