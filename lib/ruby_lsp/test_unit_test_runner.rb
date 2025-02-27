# typed: true
# frozen_string_literal: true

require "test/unit"
require "test/unit/ui/testrunner"
require "stringio"
require "ruby_lsp/test_reporter"

module RubyLsp
  class TestRunner < ::Test::Unit::UI::TestRunner
    #: (::Test::Unit::TestCase test) -> void
    def test_started(test)
      current_test = test
      @current_file = file_for_test(current_test)
      @current_test_id = "#{current_test.class.name}##{current_test.method_name}"
      result = {
        id: @current_test_id,
        file: @current_file,
      }
      TestReporter.start_test(**result)
    end

    #: (::Test::Unit::TestCase test) -> void
    def test_finished(test)
      if test.passed?
        # tests with an Omission are still marked as passed, which seems strange
        # return if test.instance_variable_get("@_result").faults.any?

        result = {
          id: @current_test_id,
          file: @current_file,
        }
        TestReporter.record_pass(**result)
      end
    end

    #: (::Test::Unit::Failure | ::Test::Unit::Error | ::Test::Unit::Pending result) -> void
    def result_fault(result)
      case result
      when ::Test::Unit::Failure
        record_failure(result)
      when ::Test::Unit::Error
        record_error(result)
      when ::Test::Unit::Pending
        record_skip(result)
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
      TestReporter.record_fail(**result)
    end

    #: (::Test::Unit::Error error) -> void
    def record_error(error)
      result = {
        id: @current_test_id,
        message: error.message,
        file: @current_file,
      }
      TestReporter.record_error(**result)
    end

    #: (::Test::Unit::Pending pending) -> void
    def record_skip(pending)
      result = {
        id: @current_test_id,
        message: pending.message,
        file: @current_file,
      }
      TestReporter.record_skip(**result)
    end

    #: (::Test::Unit::TestCase test) -> String
    def file_for_test(test)
      location = test.method(test.method_name).source_location
      return "" unless location # TODO: when might this be nil?

      file, _line = location
      return "" if file.start_with?("(eval at ") # test is dynamically defined (TODO: better way to check?)

      File.expand_path(file, __dir__)
    end

    #: -> void
    def attach_to_mediator
      @mediator.add_listener(Test::Unit::TestResult::FAULT, &method(:result_fault))
      @mediator.add_listener(Test::Unit::TestCase::STARTED_OBJECT, &method(:test_started))
      @mediator.add_listener(Test::Unit::TestCase::FINISHED_OBJECT, &method(:test_finished))
    end
  end
end

Test::Unit::AutoRunner.register_runner(:ruby_lsp) { |_auto_runner| RubyLsp::TestRunner }
