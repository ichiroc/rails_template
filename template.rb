# coding: utf-8
# frozen_string_literal: true

def windows?
  RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/
end

has_user = yes? 'Do you want to add devise, rolify, pudint gems? [y/n]'
if has_user and yes? 'Do you want to add devise model right now? [y/n]'
  devise_model = ask 'Type devise model name (DON\'T INCLUDE OPTIONS) : [User]'
  devise_model = 'User' if devise_model.blank?
  devise_model_options = ask "Type devise model options : rails g devise #{devise_model}"
end

if has_user
  gem 'devise'
  gem 'rolify'
  gem 'pundit'
end

gem 'haml-rails'
gem 'kaminari'
gem 'simple_form'
gem 'twitter-bootstrap-rails'

gem_group :development, :test do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem "font-awesome-rails"
  gem 'guard-rspec'
  gem 'launchy'
  gem 'letter_opener'
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
end

# Because it will fail install, skip these gems if it run on Windows.
unless windows?
  gem 'therubyracer'
  gem "less-rails"
end

run 'bundle install'
run 'bundle exec guard init'

generate 'bootstrap:install'
generate 'bootstrap:layout'
generate 'simple_form:install', '--bootstrap'
generate 'annotate:install'
generate 'rspec:install'

# Uncomment Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f } in spec/rails_helper.rb
uncomment_lines 'spec/rails_helper.rb', /Dir.*spec\/support\/.*/

inject_into_file 'spec/rails_helper.rb', before: "\nend\n" do
  "\n  config.include FactoryGirl::Syntax::Methods\n"
end
if has_user
  generate 'devise:install'
  environment %q(config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }), env: 'development'
  generate "devise #{devise_model} #{devise_model_options}" if devise_model
  generate 'pundit:install'
  generate "rolify Role #{devise_model}"
end


rake 'erb2haml'
rails_command 'db:migrate' if yes? 'Migrate db?'
run 'pessimize -c patch'
run 'rm Gemfile.backup'
run 'rm Gemfile.lock.backup'
environment 'config.action_mailer.delivery_method = :letter_opener', env: 'development'

remove_file '.gitignore'
get 'https://www.gitignore.io/api/rails%2Cmacos%2Cemacs', '.gitignore'
