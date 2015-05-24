require File.expand_path("../../../../db/connection",__FILE__)

require "ans/key_value_store"

require "minitest/autorun"
require "minitest/power_assert"
require "pry"

require "database_cleaner"

DatabaseCleaner.strategy = :transaction

class Minitest::Test
  def setup
    super
    DatabaseCleaner.start
  end
  def teardown
    super
    DatabaseCleaner.clean
  end
end
