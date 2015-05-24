require "ans/key_value_store/version"

require "active_support/configurable"
require "active_support/concern"

module Ans
  module KeyValueStore
    include ActiveSupport::Configurable
    extend ActiveSupport::Concern

    configure do |config|
      config.default_store_name = :data
      config.default_key_column = :key
      config.default_value_column = :value
      config.categories_method_name = :categories
      config.category_method_name = :category
      config.category_label_method_name = :category_label
      config.category_scope_name = :category
    end

    autoload :Data, "ans/key_value_store/data"

    class_methods do
      def key_value_store(store_name=nil, key: nil, value: nil, &block)
        config = KeyValueStore.config

        store_name ||= config.default_store_name
        key_column = key || config.default_key_column
        value_column = value || config.default_value_column
        model = self

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

              attr_accessor *schema.columns.map{|column| column.name}
            end

            schema
          end
          define_method :reload do
            clear_data
            begin
              model.all.each do |row|
                set row.__send__(key_column), row.__send__(value_column)
              end
            rescue ActiveRecord::StatementInvalid
            end

            schema.columns.each do |column|
              unless data.key? column.name.to_sym
                begin
                  row = model.new(
                    key_column => column.name,
                    value_column => column.default,
                  )
                  row.save validate: false
                rescue ActiveRecord::StatementInvalid
                end
                set column.name, column.default
              end
            end
          end
        end

        data_class.class_exec &block
        data_class.schema = schema

        data_class.class_eval do
          validate_hash.each do |column,validate_info|
            validates column, **validate_info
          end
        end

        self.class_eval do
          scope config.category_scope_name, ->(name){
            if name
              raise KeyError, "category not defined [#{name}]" unless category_info.has_key?(name.to_sym)
            end
            where(key_column => category_key_hash[name.try(:to_sym)])
          }

          after_create do |model|
            data_class.set model.key, model.value
          end
          after_update do |model|
            data_class.set model.key, model.value
          end

          validate :has_valid_key_value_store_value

          define_method :has_valid_key_value_store_value do
            key = __send__(key_column).to_sym
            value = __send__(value_column)
            data = self.class.__send__(:"build_#{store_name}")

            data.__send__("#{key}=",value)
            data.valid?
            if data.errors.key?(key)
              errors[:base] = data.errors[key]
            end
          end

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
          define_method :"build_#{store_name}" do
            data_class.build_from_data
          end
          define_method config.category_label_method_name do |name|
            if name
              raise KeyError, "category not found [#{name}]" unless category_info.has_key?(name.to_sym)
            end
            category_info[name.try(:to_sym)].try(:fetch,:label).to_s
          end
          define_method config.categories_method_name do
            category_info
          end

          delegate(:eval_if_changed, :reload, to: data_class)

          schema.columns.each do |column|
            define_method column.name do
              data_class.get(column.name)
            end
          end
        end

      end
    end
  end
end
