require "ans/key_value_store/version"

require "active_support/configurable"

module Ans
  module KeyValueStore
    include ActiveSupport::Configurable

    configure do |config|
      config.default_store_name = :data
      config.default_key_column = :key
      config.default_value_column = :value
    end

    autoload :Data, "ans/key_value_store/data"

    def self.included(m)
      config = KeyValueStore.config

      (class << m; self; end).class_eval do
        define_method :key_value_store do |store_name=nil, key: nil, value: nil, &block|
          store_name ||= config.default_store_name

          schema = connection.__send__ :create_table_definition, :data, false, nil

          data_class = const_set store_name.to_s.camelize, Class.new(Data)
          (class << data_class; self; end).class_eval do
            define_method :schema do |&td_block|
              if td_block
                schema.tap(&td_block)

                define_attribute_methods schema.columns.map{|column| column.name}

                data_class.class_eval do
                  schema.columns.each do |column|
                    define_method column.name do
                      attribute_read column.name
                    end
                    define_method "#{column.name}=" do |value|
                      attribute_write column.name, value
                    end
                  end
                end
              end

              schema
            end
          end

          data_class.class_exec &block

          data = data_class.new(
            schema: schema,
            model: self,
            key_column: key || config.default_key_column,
            value_column: value || config.default_value_column,
          )

          (class << self; self; end).class_eval do
            define_method store_name do
              data
            end

            delegate(:eval_if_changed, to: store_name)

            schema.columns.each do |column|
              define_method column.name do
                data.attribute_read_stored column.name
              end
            end
          end
        end
      end
    end
  end
end
