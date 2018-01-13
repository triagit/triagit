FROM ruby:2.5.0

RUN wget -qO /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 && \
    chmod +x /usr/bin/dumb-init && \
    echo 'gem: --no-ri --no-rdoc' >> /etc/gemrc

WORKDIR /src
COPY Gemfile* /src/
RUN bundle install

ENV RAILS_ENV development
ENV DISABLE_SPRING 1
ENV LANG C.UTF-8
ENV PORT 3000
EXPOSE 3000
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bundle", "exec", "foreman", "start", "-f", "Procfile.production", "-e", ".env.stub"]

COPY . .
