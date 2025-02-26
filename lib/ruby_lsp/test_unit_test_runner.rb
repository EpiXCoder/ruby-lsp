# typed: false
# frozen_string_literal: true

require "test/unit"
require "test/unit/ui/testrunner"
require "stringio"

# Example of usage (using test/unit's own tests)
# RUBYOPT=-r../../Shopify/ruby-lsp/lib/ruby_lsp/test_unit_test_runner.rb bundle exec ruby test/run-test.rb --runner=ruby_lsp

require "ruby_lsp/test_reporter"

module ::Test
  module Unit
    class TestCase
      alias_method :original_run, :run

      def run(...)
        # ::RubyLsp::TestRunner.capture_io(self) do
        original_run(...)
        # end
      end

      # TODO: restore original name after
    end
  end
end

module RubyLsp
  class TestRunner < ::Test::Unit::UI::TestRunner
    #: (Test::Unit::TestSuite suite, Hash[Symbol, untyped] options) -> void
    def initialize(suite, options = {})
      @reporter = options[:reporter] || ::RubyLsp::TestReporter
      super(suite, options)
    end

    private

    #: (::Test::Unit::TestCase test) -> void
    def test_started(test)
      current_test = test
      @current_file = file_for_test(current_test)
      @current_test_id = "#{current_test.class.name}##{current_test.method_name}"
      result = {
        id: @current_test_id,
        file: @current_file,
      }
      @reporter.start_test(**result)
    end

    #: (::Test::Unit::TestCase test) -> void
    def test_finished(test)
      if test.passed?
        result = {
          id: @current_test_id,
          file: @current_file,
        }
        @reporter.record_pass(**result)
      end
    end

    #: (::Test::Unit::Failure | ::Test::Unit::Omission | ::Test::Unit::Error result) -> void
    def result_fault(result)
      case result
      when ::Test::Unit::Failure
        record_failure(result)
      when ::Test::Unit::Omission
        record_skip(result)
      when ::Test::Unit::Error
        record_error(result)
      end
    end

    #: (::Test::Unit::Failure failure) -> void
    def record_failure(failure)
      result = {
        id: @current_test_id,
        type: failure.class.name,
        message: failure.message,
        file: @current_file,
      }
      @reporter.record_fail(**result)
    end

    #: (::Test::Unit::Error error) -> void
    def record_error(error)
      result = {
        id: @current_test_id,
        message: error.message,
        file: @current_file,
      }
      @reporter.record_error(**result)
    end

    #: (::Test::Unit::Omission omission) -> void
    def record_skip(omission)
      result = {
        id: @current_test_id,
        message: omission.message,
        file: @current_file,
      }
      @reporter.record_skip(**result)
    end

    #: (::Test::Unit::TestCase test) -> String
    def file_for_test(test)
      location = Kernel.const_source_location(test.class.name)
      return "" unless location # TODO: when might this be nil?

      file, _line = location
      return "" if file.start_with?("(eval at ") # test is dynamically defined (TODO: better way to check?)

      file
    end

    #: -> void
    def attach_to_mediator
      @mediator.add_listener(Test::Unit::TestResult::FAULT, &method(:result_fault))
      @mediator.add_listener(Test::Unit::TestCase::STARTED_OBJECT, &method(:test_started))
      @mediator.add_listener(Test::Unit::TestCase::FINISHED_OBJECT, &method(:test_finished))
    end

    # based on minitest's capture_io
    class << self
      def capture_io(test, &block)
        captured_stdout = StringIO.new
        captured_stderr = StringIO.new

        orig_stdout = $stdout
        orig_stderr = $stderr
        $stdout = captured_stdout
        $stderr = captured_stderr

        yield

        # TODO: also handle stderr
      ensure
        $stdout = orig_stdout
        $stderr = orig_stderr
        unless captured_stdout.string.empty?
          id = "#{test.class.name}##{test.method_name}"
          ::RubyLsp::TestReporter.append_output(id: id, output: captured_stdout.string)
        end
      end
    end
  end
end

Test::Unit::AutoRunner.register_runner(:ruby_lsp) { |_auto_runner| RubyLsp::TestRunner }
