# triagit

> triage it, git!

`triagit` is a github app that helps triage git repositories and automate common git workflows:

- Closing outdated issues/PRs/branches
- Adding webhooks and custom bot commands
- Adding title, description, rebasing and other rules
- Moving boards/cards based to git actions
- Automating assignment and approval processes
- Requiring signed commits and CLAs
- Restricting PR diffs and sizes
- etc.

## Quickstart

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Follow the [Quickstart wiki](https://github.com/triagit/triagit/wiki/Quickstart).

## Under development

`triagit` is under active development.

We will keep the `triagit.yaml` file contract compatible,
but internal code and deployment configuration such as
environment variables can keep changing.

## Local development

* `docker-compose build`: Build image
* `docker-compose up -d postgres redis`: Starts postgres and redis in the background
* `docker-compose run --rm --service-ports web bash`: Starts development shell
  * `rake db:create db:migrate`: creates and initializes database
  * `rake spec`: runs tests (not much for now)
  * `foreman start -f Procfile.dev`: start server
  * `http://<your-docker-ip>:3000`
