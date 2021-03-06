source 'https://rubygems.org'
ruby '>= 2.5.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.1'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '~> 2.13'
  # gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  # gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

###
### Custom gems
###

group :development, :test do
  gem 'rubocop', '~> 0.49.1', require: false
  gem 'annotate', '~> 2.7.2'
  gem 'rspec-rails', '~> 3.6.0'
end

gem 'pg'
gem 'awesome_print', '~> 1.8'
gem 'dotenv-rails', '~> 2.2'
gem 'faraday-http-cache', '~> 2.0'
gem 'jwt', '~> 1.5.0'
gem 'octokit', '~> 4.0'
gem 'graphql-client', '~> 0.12'
gem 'rails_semantic_logger', '~> 4.2'
gem 'slim-rails', '~> 3.1'
gem 'omniauth', '~> 1.6'
gem 'omniauth-github', '~> 1.3'
gem 'redis-rails', '~> 5.0'
gem 'resque', '~> 1.27'
gem 'resque-scheduler', '~> 4.3'
gem 'active_scheduler', '~> 0.5'
gem 'foreman', '~> 0.84.0'
gem 'activeadmin', '~> 1.2.1'
