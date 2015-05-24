require File.expand_path("../connection",__FILE__)

ActiveRecord::Schema.define do
  drop_table :test_settings rescue nil
end
