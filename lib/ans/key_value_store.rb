require "ans/key_value_store/version"

require "active_support/configurable"

module Ans
  module KeyValueStore
    include ActiveSupport::Configurable

    configure do |config|
      config.default_store_name = :data
      config.default_key_column = :key
      config.default_value_column = :value
      config.category_method_name = :category
      config.category_label_method_name = :category_label
      config.category_scope_name = :category
    end

    autoload :Data, "ans/key_value_store/data"

    def self.included(m)
      config = KeyValueStore.config

      (class << m; self; end).class_eval do
        define_method :key_value_store do |store_name=nil, key: nil, value: nil, &block|
          store_name ||= config.default_store_name

          validate_hash = {}
          category_hash = {}
          category_key_hash = {}
          category_info = {}
          current_category = nil

          schema = connection.__send__ :create_table_definition, :data, false, nil
          schema.class_eval do
            define_method :column_with_key_value_store do |column,type,options|
              category_hash[column.to_sym] = current_category
              category_key_hash[current_category] ||= []
              category_key_hash[current_category] << column.to_sym

              if validate_info = options.delete(:validates)
                validate_hash[column] = validate_info
              end
              column_without_key_value_store column, type, options
            end
            alias_method_chain :column, :key_value_store
          end

          data_class = const_set store_name.to_s.camelize, Class.new(Data)
          (class << data_class; self; end).class_eval do
            define_method :category do |category_name,label:nil,&block|
              current_category = category_name.to_sym
              category_info[category_name.to_sym] = {
                name: category_name.to_sym,
                label: label || category_name.to_s.humanize,
              }
              block.call
              current_category = nil
            end
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
                    define_method "#{column.name}_record" do
                      attribute_record column.name
                    end
                  end
                end
              end

              schema
            end
          end

          data_class.class_exec &block
          data_class.class_eval do
            validate_hash.each do |column,validate_info|
              validates column, **validate_info
            end
          end

          key_column = key || config.default_key_column
          value_column = value || config.default_value_column

          data = data_class.new(
            schema: schema,
            model: self,
            key_column: key_column,
            value_column: value_column,
          )

          self.class_eval do
            scope config.category_scope_name, ->(name){
              if name
                raise KeyError, "category not defined [#{name}]" unless category_info.has_key?(name.to_sym)
              end
              where(key_column => category_key_hash[name.try(:to_sym)])
            }
            define_method config.category_method_name do
              key = self.send(key_column).try(:to_sym)
              raise KeyError, "key not defined [#{key}]" unless category_hash.has_key?(key)
              category_hash[key]
            end
            define_method config.category_label_method_name do
              key = self.send(key_column).try(:to_sym)
              raise KeyError, "key not defined [#{key}]" unless category_hash.has_key?(key)
              category_info[category_hash[key]].try(:fetch,:label).to_s
            end
          end
          (class << self; self; end).class_eval do
            define_method store_name do
              data
            end
            define_method config.category_label_method_name do |name|
              if name
                raise KeyError, "category not found [#{name}]" unless category_info.has_key?(name.to_sym)
              end
              category_info[name.try(:to_sym)].try(:fetch,:label).to_s
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
