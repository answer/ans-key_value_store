module Ans
  module KeyValueStore
    class Data
      include ActiveModel::Model

      class << self
        attr_accessor :schema

        def build_from_data
          new data
        end

        def get(key)
          key = key.to_sym
          @accessed_keys.try(:push, key)
          data[key]
        end
        def set(key,value)
          key = key.to_sym
          data[key] = type(key).type_cast_from_user(value)
          eval_observing_blocks key
        end
        def eval_if_changed(&block)
          @accessed_keys = []

          result = block.call

          unless @accessed_keys.blank?
            info = [block, @accessed_keys]
            observing_blocks << info
          end
          @accessed_keys = nil

          result
        end

        private
          def data
            @data ||= {}
          end
          def clear_data
            @data = {}
          end

          def observing_blocks
            @observing_blocks ||= []
          end
          def eval_observing_blocks(changed_key)
            observing_blocks.each do |block,accessed_keys|
              block.call if accessed_keys.include?(changed_key)
            end
          end

          def type(key)
            @types ||= {}
            @types[key] ||= begin
              column = @schema.columns.find{|column| column.name.to_sym == key}

              column_type = column.try(:type) || :string
              case column_type
              when :bigint
                type_name = "BigInteger"
              when :datetime
                type_name = "DateTime"
              else
                type_name = column_type.to_s.camelize
              end
              "ActiveRecord::Type::#{type_name}".constantize.new(
                precision: column.try(:precision),
                limit: column.try(:limit),
                scale: column.try(:scale),
              )
            end
        end
      end

      def new_record?
        false
      end
      def persisted?
        true
      end

      def attributes
        self.class.schema.columns.map{|column| [column.name,__send__(column.name)]}.to_h
      end
    end
  end
end
