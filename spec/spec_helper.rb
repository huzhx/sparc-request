# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
# require 'database_cleaner'
require 'factory_girl'
require 'faker'

# Add this to load Capybara integration:
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/dsl'
require 'selenium-webdriver'

# Set default values for capybara; these can be overriden by a file in
# the support directory (see below).  For example, to use poltergeist,
# create file spec/support/poltergeist.rb that contains:
#
#   require 'capybara/poltergeist'
#   Capybara.javascript_driver = :poltergeist
#
# You can also enable firebug:
#
#   require 'capybara/firebug'
#   Capybara.javascript_driver = :selenium_with_firebug
#

profile = Selenium::WebDriver::Firefox::Profile.new
profile["focusmanager.testmode"] = true

Capybara.register_driver :selenium_firefox_focus do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
end

Capybara.javascript_driver = :selenium_firefox_focus
Capybara.default_wait_time = 15

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
include CapybaraSupport

# I'm not sure why this is necessary.  None of the examples at
# https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
# seem to do this, but without it, we get the error "ArgumentError:
# Trait not registered: id".
FactoryGirl.define do
  sequence :id do |id|
    id
  end
end

def load_schema
  load_schema = lambda {
    basedir = File.expand_path(File.dirname(__FILE__))
    load File.join(basedir, '../db/schema.rb')
  }
  # silence_stream(STDOUT, &load_schema)
  load_schema.call
end

# We need to load the schema if we are using the in-memory sqlite3
# database; if we are using mysql, we can save some time by skipping
# this step.
ar_config = ActiveRecord::Base.configurations[Rails.env]
if ar_config['adapter'] == 'sqlite3' and ar_config['database'] == ':memory:' then
  load_schema()
end

FactoryGirl.find_definitions

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) { DatabaseCleaner.start }
  config.after(:each) { DatabaseCleaner.clean }

  config.color_enabled = true
end

