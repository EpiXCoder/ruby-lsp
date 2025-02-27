# typed: true
# frozen_string_literal: true

require "test_helper"
require "stringio"

module RubyLsp
  class TestUnitTestRunnerTest < Minitest::Test
    def test_test_runner_output
      stdout, _stderr, _status = Open3.capture3(
        "bundle",
        "exec",
        "ruby",
        "test/fixtures/test_unit_example.rb",
        "--runner",
        "ruby_lsp",
      )
      actual = parse_output(stdout)

      project_path = File.expand_path("lib/ruby_lsp")

      expected = [
        {
          "event" => "start",
          "id" => "Sample#test_that_fails",
          "uri" => "file://#{project_path}/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "fail",
          "id" => "Sample#test_that_fails",
          "type" => "Test::Unit::Failure",
          "message" => "<1> expected but was\n<2>.",
          "uri" => "file://#{project_path}/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "start",
          "id" => "Sample#test_that_is_pending",
          "uri" => "file://#{project_path}/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "skip",
          "id" => "Sample#test_that_is_pending",
          "message" => "pending test",
          "uri" => "file://#{project_path}/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "start",
          "id" => "Sample#test_that_passes",
          "uri" => "file://#{project_path}/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "pass",
          "id" => "Sample#test_that_passes",
          "uri" => "file://#{project_path}/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "start",
          "id" => "Sample#test_that_raises",
          "uri" => "file://#{project_path}/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "error",
          "id" => "Sample#test_that_raises",
          "message" => "RuntimeError: oops",
          "uri" => "file://#{project_path}/test/fixtures/test_unit_example.rb",
        },
      ]
      assert_equal(expected, actual)
    end

    private

    def parse_output(shell_output)
      output = StringIO.new(shell_output)
      result = []
      while (headers = output.gets("\r\n\r\n"))
        content_length = headers[/Content-Length: (\d+)/i, 1]
        data = output.read(Integer(content_length))
        json = JSON.parse(T.must(data))
        result << json
      end
      result
    end
  end
end
