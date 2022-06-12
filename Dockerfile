# Use an official Python runtime based on Debian 10 "buster" as a parent image.
FROM python:3.10.5-slim-buster

# Port used by this container to serve HTTP.
EXPOSE 8000

# Set environment variables.
# 1. Force Python stdout and stderr streams to be unbuffered.
# 2. Set PORT variable that is used by Gunicorn. This should match "EXPOSE"
#    command.
# 3. Change settings to use production settings
ENV PYTHONUNBUFFERED=1 \
    PORT=8001 \
    DJANGO_SETTINGS_MODULE=elsword_guide.settings.production

ARG WORK_DIR=/home/app

# Install system packages required by Wagtail and Django.
RUN apt-get update --yes --quiet && apt-get install --yes --quiet --no-install-recommends \
    build-essential \
    libpq-dev \
    libmariadbclient-dev \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libwebp-dev
RUN apt-get install --yes --quiet \
    nginx \
&& rm -rf /var/lib/apt/lists/*

WORKDIR ${WORK_DIR}

# Install pipenv
RUN pip install pipenv

# Install the project requirements.
COPY Pipfile ${WORK_DIR}/
COPY Pipfile.lock ${WORK_DIR}/
RUN pipenv install --system

# Copy the source code of the project into the container.
COPY . ${WORK_DIR}/.

# Collect static files.
RUN python manage.py collectstatic --noinput --clear

# Runtime command that executes when "docker run" is called, it does the
# following:
#   1. Migrate the database.
#   2. Start the application server.
# WARNING:
#   Migrating database at the same time as starting the server IS NOT THE BEST
#   PRACTICE. The database should be migrated manually or using the release
#   phase facilities of your hosting platform. This is used only so the
#   Wagtail instance can be started with a simple "docker run" command.
CMD ["/bin/bash", "run_prod.sh"]
