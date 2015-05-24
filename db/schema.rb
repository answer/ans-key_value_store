require File.expand_path("../connection",__FILE__)

ActiveRecord::Schema.define do
  drop_table :test_settings rescue nil
  create_table :test_settings do |t|
    t.string :key
    t.text :value
  end rescue nil
end
