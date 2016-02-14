source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '~>4.2.0'
gem 'pg'

#View related stuff
gem 'jquery-rails'
gem 'bootstrap-sass'
gem 'haml-rails'
gem 'sass-rails'
gem 'prawn'
gem 'prawn-table'

gem 'paperclip' #upload additional attachments for emails

gem 'days360'

group :development do
  gem 'better_errors'         # Nicer exception pages in development
  gem 'binding_of_caller'     # Used for better errors
  gem 'sqlite3'
  gem 'coffee-rails'
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier'
  gem 'spring'
end

gem 'byebug', group: [:development, :test]

group :test do
  gem 'cucumber', '~>1.0' #2.0 is broken with RubyMine
  gem 'cucumber-rails', :require => false
  gem 'launchy'
  gem 'database_cleaner'
  gem 'timecop'
  gem 'test-unit'
  gem 'pdf-inspector', :require => 'pdf/inspector'   #To test the output of PDFs
  gem "codeclimate-test-reporter", require: nil #To get code coverage
end



