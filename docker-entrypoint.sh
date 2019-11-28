#!/bin/bash
set -e

#if [ "$1" = 'sqlite3' ]; then
if [ ! -f ./config/settings.yml ]; then
  echo "settings.yml not found, copying template.."
  cp ./config/settings.yml_template ./config/settings.yml
fi
# TODO: add different environments here!
if [ ! -f ./db/test.sqlite3 ]; then
  echo "database not found, copying template and building db.."
  cp ./config/database.yml_template_sqlite3 ./config/database.yml
  rake db:setup
  rake db:migrate
  #cp ./db/seed.rb_template ./db/seed.rb
  #rake db:seed
  #rake assets:precompile
fi
exec "$@"
