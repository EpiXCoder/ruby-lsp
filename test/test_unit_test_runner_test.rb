# typed: true
# frozen_string_literal: true

require "test_helper"

module RubyLsp
  class TestUnitTestRunnerTest < Minitest::Test
    def test_detects_no_test_library_when_there_are_no_dependencies
      # TODO: call this programmatically
      output = %x(bundle exec ruby test/fixtures/test_unit_example.rb --runner ruby_lsp)
      actual = output.lines.map(&:strip).map { JSON.parse(_1) }
      expected = [
        {
          "event" => "start",
          "id" => "Sample#test_that_fails",
          "file" => "test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "fail",
          "id" => "Sample#test_that_fails",
          "type" => "Test::Unit::Failure",
          "message" => "<1> expected but was\n<2>.",
          "file" => "test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "start",
          "id" => "Sample#test_that_passes",
          "file" => "test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "pass",
          "id" => "Sample#test_that_passes",
          "file" => "test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "start",
          "id" => "Sample#test_that_raises",
          "file" => "test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "error",
          "id" => "Sample#test_that_raises",
          "message" => "RuntimeError: oops",
          "file" => "test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "start",
          "id" => "Sample#test_that_skips",
          "file" => "test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "skip",
          "id" => "Sample#test_that_skips",
          "message" => "skipped test",
          "file" => "test/fixtures/test_unit_example.rb",
        },
        # TODO: this shouldn't be here
        {
          "event" => "pass",
          "id" => "Sample#test_that_skips",
          "file" => "test/fixtures/test_unit_example.rb",
        },
      ]
      assert_equal(expected, actual)
    end
  end
end
