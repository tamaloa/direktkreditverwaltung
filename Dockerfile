FROM ruby:2.1.10

ENV APP_HOME /usr/src/app

# throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

EXPOSE 3000

# Start server in docker-compose.yml
# CMD ["rails", "server", "-b", "0.0.0.0"]
# CMD ["rails", "server", "-e production -b", "0.0.0.0"]

# Because of backport error, see https://superuser.com/questions/1423486/issue-with-fetching-http-deb-debian-org-debian-dists-jessie-updates-inrelease
RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list

# RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
# RUN apt-get update && apt-get install -y mysql-client postgresql-client --no-install-recommends && rm -rf /var/lib/apt/lists/*
# We only need sqlite?
RUN apt-get update && apt-get install -y sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

COPY Gemfile $APP_HOME/

# Uncomment the line below if Gemfile.lock is maintained outside of build process
COPY Gemfile.lock $APP_HOME/

RUN bundle install
# RUN bundle update

# copy app to container
ADD . $APP_HOME/

# rename template files to concrete files (maybe its not working because host-folder will be mounted by docker)
#COPY config/database.yml_template_sqlite config/database.yml
#COPY config/settings.yml_template_sqlite config/settings.yml

# to initialize database with mounted host-folders you must run these commands again initialy
#RUN rake db:setup RAILS_ENV=production
#RUN rake db:migrate RAILS_ENV=production
#RUN rake assets:precompile

