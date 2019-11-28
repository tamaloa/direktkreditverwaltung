FROM ruby:2.1.10

ENV APP_HOME /usr/src/app

# throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

EXPOSE 3000

# Because of backport error, see https://superuser.com/questions/1423486/issue-with-fetching-http-deb-debian-org-debian-dists-jessie-updates-inrelease
RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list
RUN apt-get update && apt-get install -y sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

COPY Gemfile $APP_HOME/
# Uncomment the line below if Gemfile.lock is maintained outside of build process
COPY Gemfile.lock $APP_HOME/

RUN bundle install

# RUN bundle update
# fails with:
# Gem::InstallError: byebug requires Ruby version >= 2.3.0.
# An error occurred while installing byebug (11.0.1), and Bundler cannot continue.
# Make sure that `gem install byebug -v '11.0.1'` succeeds before bundling.

# copy app to container
ADD . $APP_HOME/

# script for first setup:
COPY docker-entrypoint.sh /usr/local/bin/
RUN /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
#CMD ["sqlite3"]
