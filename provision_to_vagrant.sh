#!/usr/bin/env bash

set -e
set -o


WORKDIR="/home/lukas/blog"
JEKYLL_SITE="${WORKDIR}/jekyll-blog"
CACHED_BUNDLE="${JEKYLL_SITE}/vendor"
OUTPUT="${JEKYLL_SITE}/_site"
TEST_SITE_VAGRANT="/www/test_blog"
PRODUCTION_SITE_VAGRANT="/www/blog"

# Make sure the virtual machine is up
vagrant up
# Use local Docker container to generate a site with Jekyll, drafts included. It uses cached Bundles for Gem
docker run \
    --rm \
    --volume "${JEKYLL_SITE}":"/srv/jekyll" \
    --volume "${CACHED_BUNDLE}":"/usr/local/bundle" \
    jekyll/jekyll:stable \
    jekyll build --drafts

# Sync the new content of Jekyll to Vagrant machine
vagrant rsync
# Copy site data to web content folder on Vagrant machine and reload nginx configuration
vagrant ssh -c "cp -r /vagrant/jekyll-blog/_site/* ${TEST_SITE_VAGRANT} && sudo nginx -s reload"