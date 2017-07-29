# recipie for building the docker image
# pulls the ruby image to use
FROM ruby:2.3-slim
MAINTAINER Nick Janetakis <nick.janetakis@gmail.com>

# runs shell scrips/commands
RUN apt-get update && apt-get install -qq -y build-essential nodejs libpq-dev postgresql-client-9.4 --fix-missing --no-install-recommends

# sets the env variable to /mobydock
ENV INSTALL_PATH /mobydock
# $ reference the env we just defined
RUN mkdir -p $INSTALL_PATH

# sets the current work directory to be the INSTALL_PATH
# that means that all commands that are run after this will be run in this directory
WORKDIR $INSTALL_PATH

# copy files from host to inside the docker container. COPY host_dir container_dir
COPY Gemfile Gemfile
# this is run in the word_dir
RUN bundle install
# copies everything from current directory into the container
COPY . .
# it's a build step that gets save s part of the container step
RUN bundle exec rake RAILS_ENV=production DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname SECRET_TOKEN=pickasecuretoken assets:precompile

# exposes assets outside the container (we'll use it for ngnix)
VOLUME ["$INSTALL_PATH/public"]

# default command that gets run after building the images. There can only be one
# CMD in the docker file
CMD bundle exec unicorn -c config/unicorn.rb
