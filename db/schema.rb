ActiveRecord::Schema.define do
  drop_table :settings rescue nil
  create_table :settings do |t|
    t.string :key
    t.text :value
  end rescue nil
end
