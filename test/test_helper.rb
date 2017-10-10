ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/rails"

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
  #config.after :all do
  #  ActiveRecord::Base.subclasses.each(&:delete_all)
  #end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
