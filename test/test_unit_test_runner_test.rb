# typed: true
# frozen_string_literal: true

require "test_helper"
require "os"

module RubyLsp
  class TestUnitTestRunnerTest < Minitest::Test
    def test_test_runner_output
      shell_output = %x(bundle exec ruby test/fixtures/test_unit_example.rb --runner ruby_lsp)
      actual = parse_output(shell_output)
      actual.each { |result| result["file"].gsub!(File.expand_path("lib/ruby_lsp"), "/absolute_path_to") }

      expected = [
        {
          "event" => "start",
          "id" => "Sample#test_that_fails",
          "file" => "file:///absolute_path_to/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "fail",
          "id" => "Sample#test_that_fails",
          "type" => "Test::Unit::Failure",
          "message" => "<1> expected but was\n<2>.",
          "file" => "file:///absolute_path_to/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "start",
          "id" => "Sample#test_that_is_pending",
          "file" => "file:///absolute_path_to/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "skip",
          "id" => "Sample#test_that_is_pending",
          "message" => "pending test",
          "file" => "file:///absolute_path_to/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "start",
          "id" => "Sample#test_that_passes",
          "file" => "file:///absolute_path_to/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "pass",
          "id" => "Sample#test_that_passes",
          "file" => "file:///absolute_path_to/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "start",
          "id" => "Sample#test_that_raises",
          "file" => "file:///absolute_path_to/test/fixtures/test_unit_example.rb",
        },
        {
          "event" => "error",
          "id" => "Sample#test_that_raises",
          "message" => "RuntimeError: oops",
          "file" => "file:///absolute_path_to/test/fixtures/test_unit_example.rb",
        },
      ]
      assert_equal(expected, actual)
    end

    private

    def parse_output(shell_output)
      output = StringIO.new(shell_output)
      output.binmode # for windows
      output.sync = true # for windows
      result = []
      linebreak = OS.windows? ? "\n" : "\r\n"
      while (headers = output.gets(linebreak * 2))
        content_length = headers[/Content-Length: (\d+)/i, 1]
        data = output.read(Integer(content_length))
        json = JSON.parse(T.must(data))
        result << json
      end
      result
    end
  end
end
