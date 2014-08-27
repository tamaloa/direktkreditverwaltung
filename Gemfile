source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '~>3.2' # otherwise 0.9.2 is installed
gem 'pg'

#View related stuff
gem 'jquery-rails'
gem 'bootstrap-sass'
gem 'haml-rails'
gem 'sass-rails'
gem 'prawn'
gem 'prawn-table'

gem 'days360'

group :development do
  gem 'better_errors'         # Nicer exception pages in development
  gem 'binding_of_caller'     # Used for better errors
end

group :test do
  gem 'cucumber'
  gem 'cucumber-rails', :require => false
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
  gem 'timecop'
  gem 'test-unit'
  gem 'pdf-inspector', :require => 'pdf/inspector'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end


