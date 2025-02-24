# typed: false
# frozen_string_literal: true

module Minitest
  module Reporters
    class Suite
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def ==(other)
        name == other.name
      end

      def eql?(other)
        self == other
      end

      def hash
        name.hash
      end

      def to_s
        name.to_s
      end
    end
  end
end
