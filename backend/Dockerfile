FROM ruby:3.2.2

# Install build dependencies
RUN apt-get update -qq && \
      apt-get install -y \
      libsqlite3-dev \
      nodejs \
      sqlite3

ENV RAILS_ENV production
ENV INSTALL_PATH /app

RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

# Ensure gems are cached and only get updated when they change. This will
# drastically increase build times when the gems do not change.
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --jobs 20 --retry 5

COPY . .

# Copy the entrypoint script into the image
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# The default command that gets ran will be to start the Puma server.
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-e", "production"]
