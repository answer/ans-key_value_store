module Ans
  module KeyValueStore
    class Data
      include ActiveModel::Model
      include ActiveModel::Dirty

      def initialize(schema:, model:, key_column:, value_column:)
        @schema = schema
        @model = model
        @key_column = key_column
        @value_column = value_column

        reset_data
        clear_changes_information
      end

      def attribute_read(key)
        receive_access(key)
        @data[key.to_sym]
      end
      def attribute_write(key,value)
        return unless respond_to?(key.to_sym)

        value = cast key, value
        attribute_will_change! key if value != @data[key.to_sym]
        @data[key.to_sym] = value
      end

      def reload
        reset_data

        if changed?
          eval_observing_blocks
          changes_applied
        end

        self
      end

      def eval_if_changed(&block)
        @accessed_keys = []

        result = block.call

        unless @accessed_keys.blank?
          observing_blocks << [block, @accessed_keys]
        end
        @accessed_keys = nil

        result
      end

      def update!(data)
        data.each do |key,value|
          attribute_write key, value
        end

        raise ActiveRecord::RecordInvalid, self if invalid?

        if changed?
          @model.transaction do
            changes.each do |key,(old,new)|
              write_to_database key, new
            end
          end

          eval_observing_blocks
          changes_applied
        end

        nil
      end
      def update(data)
        update!(data)
        true
      rescue ActiveRecord::RecordInvalid
        false
      end

      def save!
        update!({})
      end
      def save
        update({})
      end

      private

      def reset_data
        @data = {}
        begin
          @model.all.each do |row|
            read_from_database row
          end
        rescue ActiveRecord::StatementInvalid
        end

        @schema.columns.each do |column|
          if !column.default.nil? && @data[column.name.to_sym].nil?
            read_from_database write_to_database column.name, column.default
          end
        end
      end
      def read_from_database(row)
        attribute_write row.__send__(@key_column), row.__send__(@value_column)
      end
      def write_to_database(key,value)
        row = @model.find_or_initialize_by(@key_column => key)
        value = value.to_s unless value.nil?
        row.__send__ "#{@value_column}=", value
        row.save! if row.changed?
        row
      end

      def receive_access(key)
        @accessed_keys.try(:push, key.to_sym)
      end
      def observing_blocks
        @observing_blocks ||= []
      end
      def eval_observing_blocks
        changed_keys = changes.keys
        observing_blocks.each do |block,accessed_keys|
          block.call if changed_keys.any?{|changed_key| accessed_keys.include?(changed_key.to_sym)}
        end
      end

      def cast(key,value)
        unless respond_to?(key)
          value
        else
          type(key.to_sym).type_cast_from_user(value)
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
            precision: column.precision,
            limit: column.limit,
            scale: column.scale,
          )
        end
      end

    end
  end
end
