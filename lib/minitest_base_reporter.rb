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

    class MyBaseReporter < Minitest::StatisticsReporter
      attr_accessor :tests

      def initialize(options = {})
        super($stdout, options)
        self.tests = []
      end

      # called by our own before hooks
      def before_test(test)
        last_test = test_class(tests.last)

        suite_changed = last_test.nil? || last_test.name != test.class.name

        return unless suite_changed

        after_suite(last_test) if last_test
        before_suite(test_class(test))
      end

      # called by our own after hooks
      def after_test(_test); end

      protected

      def after_suite(test); end

      def before_suite(test); end

      def test_class(result)
        # Minitest broke API between 5.10 and 5.11 this gets around Result object
        if result.nil?
          nil
        elsif result.respond_to?(:klass)
          Suite.new(result.klass)
        else
          Suite.new(result.class.name)
        end
      end

      def filter_backtrace(backtrace)
        Minitest.filter_backtrace(backtrace)
      end
    end
  end
end
