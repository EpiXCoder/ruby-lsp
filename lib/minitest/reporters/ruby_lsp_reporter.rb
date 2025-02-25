# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require "ruby_lsp/test_reporter"

# NOTE: minitest-reporters mentioned an API change between minitest 5.10 and 5.11, so we should limit our support
# https://github.com/minitest-reporters/minitest-reporters/blob/265ff4b40d5827e84d7e902b808fbee860b61221/lib/minitest/reporters/base_reporter.rb#L82-L91

# TODO: the other reporters call print_info for formatting and backtrace filtering. Look into if we should also do that.

require "minitest"
require "minitest_suite"

module Minitest
  module Reporters
    class RubyLspReporter < ::Minitest::Reporter # TODO: can this inherit from AbstractReporter?
      extend T::Sig

      sig { returns(T::Array[Minitest::Test]) }
      attr_accessor :tests

      sig { void }
      def initialize
        @reporting = T.let(RubyLsp::TestReporter.new, RubyLsp::TestReporter)
        @tests = T.let([], T::Array[Minitest::Test])
        super($stdout, {})
      end

      sig { params(test: Minitest::Test).void }
      def before_test(test)
        @reporting.before_test(
          id: id_from_test(test),
          file: file_for_test(test),
        )
        last_test = test_class(tests.last)

        suite_changed = last_test.nil? || last_test.name != test.class.name

        return unless suite_changed

        after_suite(last_test) if last_test
        before_suite(test_class(test))
      end

      sig { params(test: Minitest::Test).void }
      def after_test(test)
        @reporting.after_test(
          id: id_from_test(test),
          file: file_for_test(test),
        )
      end

      sig { params(test: Minitest::Result).void }
      def record(test)
        super

        if test.passed?
          record_pass(test)
        elsif test.skipped?
          record_skip(test)
        elsif test.failure
          record_fail(test)
        end
      end

      sig { params(result: Minitest::Result).void }
      def record_pass(result)
        info = {
          id: id_from_result(result),
          file: result.source_location[0],
        }
        @reporting.record_pass(**info)
      end

      sig { params(result: Minitest::Result).void }
      def record_skip(result)
        info = {
          id: id_from_result(result),
          message: result.failure.message,
          file: result.source_location[0],
        }
        @reporting.record_skip(**info)
      end

      sig { params(result: Minitest::Result).void }
      def record_fail(result)
        info = {
          id: id_from_result(result),
          type: result.failure.class.name,
          message: result.failure.message,
          file: result.source_location[0],
        }
        @reporting.record_fail(**info)
      end

      private

      sig { params(suite: Suite).void }
      def after_suite(suite)
      end

      sig { params(suite: Suite).void }
      def before_suite(suite)
      end

      sig { params(result: T.nilable(Minitest::Test)).returns(T.nilable(Suite)) }
      def test_class(result)
        if result.nil?
          nil
        else
          Suite.new(result.class.name)
        end
      end

      sig { params(test: Minitest::Test).returns(String) }
      def id_from_test(test)
        "#{test.class.name}##{test.name}"
      end

      sig { params(result: Minitest::Result).returns(String) }
      def id_from_result(result)
        [result.klass, result.name].join("#")
      end

      sig { params(test: Minitest::Test).returns(String) }
      def file_for_test(test)
        location = Kernel.const_source_location(test.class_name)
        return "" unless location # TODO: when might this be nil?

        file, _line = location
        return "" if file.start_with?("(eval at ") # test is dynamically defined (TODO: better way to check?)

        file
      end
    end
  end
end
