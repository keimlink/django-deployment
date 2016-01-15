#!/usr/bin/env bash
# Test Django deployment

set -o errexit
set -o nounset
set -o pipefail
set -o verbose

cd /src

# Install requirements
pip install -r requirements.txt

# Run migrations
./manage.py migrate
./manage.py migrate --database=newsdb

# Run deployment checks
./manage.py check --deploy

# Create a new superuser 'admin'
python - <<EOF
import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "cookbook.settings")

from django.db.utils import IntegrityError
from django.contrib.auth.models import User
try:
    User.objects.create_superuser("admin", "admin@example.com", "admin")
except IntegrityError:
    pass
EOF

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
