# typed: true
# frozen_string_literal: true

require "test_helper"

module RubyLsp
  class TestUnitTestRunnerTest < Minitest::Test
    def test_test_runner_output
      shell_output = %x(bundle exec ruby test/fixtures/test_unit_example.rb --runner ruby_lsp)

      # temporary debug for windows
      puts shell_output

      actual = parse_output(shell_output)

      actual.each { |result| result["file"].gsub!(Dir.pwd + "/lib/ruby_lsp/", "/absolute_path_to/") }

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
      while (headers = output.gets("\r\n\r\n"))
        content_length = headers[/Content-Length: (\d+)/i, 1]

        data = output.read(Integer(content_length))
        break unless data # windows hack

        json = JSON.parse(data)
        result << json
      end
      result
    end
  end
end
