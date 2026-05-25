# frozen_string_literal: true

module DataImport
  module Brasfoot
    class JavaSerializationReader
      STREAM_MAGIC = 0xaced
      STREAM_VERSION = 5
      BASE_HANDLE = 0x7e0000

      TC_NULL = 0x70
      TC_REFERENCE = 0x71
      TC_CLASSDESC = 0x72
      TC_OBJECT = 0x73
      TC_STRING = 0x74
      TC_ARRAY = 0x75
      TC_CLASS = 0x76
      TC_BLOCKDATA = 0x77
      TC_ENDBLOCKDATA = 0x78
      TC_RESET = 0x79
      TC_BLOCKDATALONG = 0x7a
      TC_EXCEPTION = 0x7b
      TC_LONGSTRING = 0x7c
      TC_PROXYCLASSDESC = 0x7d
      TC_ENUM = 0x7e

      SC_WRITE_METHOD = 0x01

      ParsedObject = Struct.new(:class_name, :fields, keyword_init: true)
      ClassDescriptor = Struct.new(:class_name, :flags, :fields, :super_class, keyword_init: true)
      Field = Struct.new(:type, :name, :class_name, keyword_init: true)

      def self.read(...)
        new(...).read
      end

      def initialize(bytes)
        @bytes = bytes.b
        @offset = 0
        @handles = {}
        @next_handle = BASE_HANDLE
      end

      def read
        magic = read_u2
        version = read_u2
        raise ArgumentError, "Unsupported Java serialization stream" unless magic == STREAM_MAGIC && version == STREAM_VERSION

        read_content
      end

      private

      attr_reader :bytes, :handles

      def read_content
        marker = read_u1

        case marker
        when TC_NULL then nil
        when TC_REFERENCE then handles.fetch(read_u4)
        when TC_OBJECT then read_object
        when TC_STRING then register_handle(read_utf(read_u2))
        when TC_LONGSTRING then register_handle(read_utf(read_u8))
        when TC_CLASSDESC then read_class_descriptor
        when TC_ARRAY then read_array
        when TC_CLASS then read_content
        when TC_ENUM then read_enum
        when TC_BLOCKDATA then read_bytes(read_u1)
        when TC_BLOCKDATALONG then read_bytes(read_u4)
        when TC_RESET
          handles.clear
          read_content
        when TC_EXCEPTION
          raise ArgumentError, "Serialized Java exception blocks are not supported"
        when TC_PROXYCLASSDESC
          raise ArgumentError, "Serialized Java proxy class descriptors are not supported"
        else
          raise ArgumentError, "Unexpected Java serialization marker 0x#{marker.to_s(16)} at offset #{@offset - 1}"
        end
      end

      def read_object
        descriptor = read_content
        object = register_handle(ParsedObject.new(class_name: descriptor.class_name, fields: {}))

        if descriptor.class_name == "java.util.ArrayList"
          object.fields["items"] = read_array_list_items(descriptor)
        else
          read_class_data(descriptor, object.fields)
        end

        object
      end

      def read_class_descriptor
        class_name = read_utf(read_u2)
        read_u8 # serialVersionUID
        flags = read_u1
        descriptor = register_handle(ClassDescriptor.new(class_name:, flags:, fields: [], super_class: nil))

        read_u2.times do
          type = read_u1.chr
          name = read_utf(read_u2)
          field_class = object_field?(type) ? read_content : nil
          descriptor.fields << Field.new(type:, name:, class_name: field_class)
        end

        read_class_annotations
        descriptor.super_class = read_content
        descriptor
      end

      def read_class_data(descriptor, target)
        read_class_data(descriptor.super_class, target) if descriptor.super_class

        descriptor.fields.each do |field|
          target[field.name] = read_field_value(field.type)
        end

        read_object_annotations if write_method?(descriptor)
      end

      def read_array_list_items(descriptor)
        values = {}
        read_class_data_without_annotations(descriptor, values)
        size = values.fetch("size")
        read_block_data # capacity, written by java.util.ArrayList#writeObject

        Array.new(size) { read_content }.tap do
          marker = read_u1
          raise ArgumentError, "Expected end of ArrayList block data" unless marker == TC_ENDBLOCKDATA
        end
      end

      def read_class_data_without_annotations(descriptor, target)
        read_class_data_without_annotations(descriptor.super_class, target) if descriptor.super_class
        descriptor.fields.each do |field|
          target[field.name] = read_field_value(field.type)
        end
      end

      def read_class_annotations
        loop do
          marker = peek_u1
          break read_u1 if marker == TC_ENDBLOCKDATA

          read_content
        end
      end

      def read_object_annotations
        loop do
          marker = peek_u1
          break read_u1 if marker == TC_ENDBLOCKDATA

          read_content
        end
      end

      def read_array
        descriptor = read_content
        length = read_u4
        register_handle(Array.new(length) { read_array_value(descriptor.class_name) }.tap do |array|
          array.define_singleton_method(:java_class_name) { descriptor.class_name }
        end)
      end

      def read_enum
        read_content
        register_handle(read_content)
      end

      def read_field_value(type)
        case type
        when "B" then read_i1
        when "C" then read_u2
        when "D" then read_f8
        when "F" then read_f4
        when "I" then read_i4
        when "J" then read_i8
        when "S" then read_i2
        when "Z" then read_u1 != 0
        when "L", "[" then read_content
        else
          raise ArgumentError, "Unsupported Java field type #{type.inspect}"
        end
      end

      def read_array_value(class_name)
        case class_name[1]
        when "B" then read_i1
        when "C" then read_u2
        when "D" then read_f8
        when "F" then read_f4
        when "I" then read_i4
        when "J" then read_i8
        when "S" then read_i2
        when "Z" then read_u1 != 0
        when "L", "[" then read_content
        else
          raise ArgumentError, "Unsupported Java array class #{class_name.inspect}"
        end
      end

      def read_block_data
        marker = read_u1
        case marker
        when TC_BLOCKDATA then read_bytes(read_u1)
        when TC_BLOCKDATALONG then read_bytes(read_u4)
        else
          raise ArgumentError, "Expected Java block data marker"
        end
      end

      def register_handle(value)
        handles[@next_handle] = value
        @next_handle += 1
        value
      end

      def object_field?(type)
        type == "L" || type == "["
      end

      def write_method?(descriptor)
        (descriptor.flags & SC_WRITE_METHOD) == SC_WRITE_METHOD
      end

      def peek_u1
        bytes.getbyte(@offset)
      end

      def read_u1
        bytes.getbyte(@offset).tap { @offset += 1 }
      end

      def read_i1
        read_bytes(1).unpack1("c")
      end

      def read_u2
        read_bytes(2).unpack1("n")
      end

      def read_i2
        read_bytes(2).unpack1("s>")
      end

      def read_u4
        read_bytes(4).unpack1("N")
      end

      def read_i4
        read_bytes(4).unpack1("l>")
      end

      def read_u8
        read_bytes(8).unpack1("Q>")
      end

      def read_i8
        read_bytes(8).unpack1("q>")
      end

      def read_f4
        read_bytes(4).unpack1("g")
      end

      def read_f8
        read_bytes(8).unpack1("G")
      end

      def read_utf(length)
        read_bytes(length).force_encoding(Encoding::UTF_8).scrub
      end

      def read_bytes(length)
        bytes.byteslice(@offset, length).tap do |chunk|
          raise ArgumentError, "Unexpected end of Java serialization stream" unless chunk&.bytesize == length

          @offset += length
        end
      end
    end
  end
end
