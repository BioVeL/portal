source 'https://rubygems.org'

gem 'rails', '3.2.14'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# We need to use mysql in development and production now to ensure that
# dumped schemas are useful and consistent.
gem "mysql2", "~> 0.3.13"

gem 'json', "~> 1.7.6"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', "~> 0.11.3", :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'

  gem 'jquery-datatables-rails', "~> 1.11.2"
  gem 'jquery-ui-rails', "~> 4.0.2"
end

gem 'jquery-rails', "~> 3.0.1"
gem "jquery-rails-cdn", "~> 1.0.1"

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0', :require => 'bcrypt'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

# T2flow gem to parse and read workflows
gem 'taverna-t2flow', "~> 0.4.3"

# Taverna Player for workflow execution and management
gem "taverna-player", "~> 0.0.1", :path => "/home/hainesr/work/taverna/src/taverna-player"
gem "t2-server", "~> 1.0.0", :path => "/home/hainesr/work/taverna/src/t2-server-gem"

# Unicorn for dev server
gem "unicorn-rails"

# Connect to my Experiment using oauth-plugin to gemfile
gem 'oauth-plugin', ">= 0.4.0.pre1"

# User authentication
gem 'devise', "~> 3.0.2"

gem "coderay", "~> 1.0.9"

gem "rails_autolink", "~> 1.1.0"

# Google analytics needs to be turned on for each environment configuration in
# which it is required
gem "google-analytics-rails", "~> 0.0.4"

# This gem MUST BE INCLUDED LAST so that it can hook into everything else!
# In this case we actually stop it from being automatically included here so
# we can turn it on in the initializers if required.
gem "rack-mini-profiler", "~> 0.1.28", :require => false
