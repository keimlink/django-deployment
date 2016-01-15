#!/usr/bin/env bash
# Test Django deployment

set -o errexit
set -o pipefail
set -o verbose

cd
# Activate virtualenv
. venv/bin/activate
cd /src
# Install requirements
pip install -r requirements.txt
# Run migrations
./manage.py migrate
./manage.py migrate --database=newsdb
# Run deployment checks
./manage.py check --deploy
# Create new superuser 'admin'
./manage.py createsuperuser --username admin --email admin@example.com
# Load initial data
./manage.py loaddata recipes initial_data
# Collect static files
./manage.py collectstatic -v0 --noinput
# Copy media files
sudo rm -fr /home/vagrant/media
cp -R media /home/vagrant
sudo chown -R www-data: /home/vagrant/media
# Restart Apache
sudo service apache2 stop
sudo service apache2 start
