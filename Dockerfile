FROM ruby:2.4

RUN apt-get -qq update && \
    apt-get install sqlite3 && \
    rm -rf /var/cache/apt /var/lib/apt/lists && \
    wget -qO /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 && \
    chmod +x /usr/bin/dumb-init

WORKDIR /src
COPY Gemfile* /src/
RUN bundle install

ENV RAILS_ENV development
EXPOSE 3000
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bundle", "exec", "rails", "server"]

COPY . .
