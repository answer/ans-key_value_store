require "active_record"

require "yaml"
database_yml = File.expand_path("../../config/database.yml",__FILE__)
ActiveRecord::Base.establish_connection YAML.load_file(database_yml)["test"]
