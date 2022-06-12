#!/bin/bash

# create nginx config
python nginx/create_nginx_config.py

# start nginx for static files
nginx

# start wagtail
set -xe

gunicorn elsword_guide.wsgi:application
