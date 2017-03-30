require 'fluent/parser'

module Fluent
  module Mixin
    module TypeConverter
      include Configurable
      include RecordFilterMixin
      include Fluent::TextParser::TypeConverter

      attr_accessor :types, :types_delimiter, :types_label_delimiter

      def configure(conf)
        super

      end

      def filter_record(tag, time, record)
        super
        if @types
          convert_field_type!(record)
        end
      end

      def convert_field_type!(record)
        record.each { |key, value|
          record[key] = convert_type(key, value)
        }
        self
      end
    end
  end
end
