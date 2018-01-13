# This file is used only by heroku
web: bundle exec foreman start -f Procfile.production -e .env.stub -p $PORT
release: bundle exec rake db:migrate
