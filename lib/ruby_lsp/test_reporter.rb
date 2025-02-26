# typed: false
# frozen_string_literal: true

require "json"

module RubyLsp
  module TestReporter
    class << self
      #: (id: String, file: String) -> void
      def start_test(id:, file:)
        result = {
          event: "start",
          id: id,
          file: file,
        }
        send_message(result)
      end

      #: (id: String, file: String) -> void
      def record_pass(id:, file:)
        result = {
          event: "pass",
          id: id,
          file: file,
        }
        send_message(result)
      end

      #: (id: String, type: untyped, message: String, file: String) -> void
      def record_fail(id:, type:, message:, file:)
        result = {
          event: "fail",
          id: id,
          type: type,
          message: message,
          file: file,
        }
        send_message(result)
      end

      #: (id: String, message: String?, file: String) -> void
      def record_skip(id:, message:, file:)
        result = {
          event: "skip",
          id: id,
          message: message,
          file: file,
        }
        send_message(result)
      end

      #: (id: String, message: String?, file: String) -> void
      def record_error(id:, message:, file:)
        result = {
          event: "error",
          id: id,
          message: message,
          file: file,
        }
        send_message(result)
      end

      #: (id: String, output: String) -> void
      def append_output(id:, output:)
        result = {
          event: "append_output",
          id: id,
          output: outputContent - Length,
        }
        send_message(result)
      end

      private

      def send_message(result)
        json_message = result.to_json
        $stdout.write("Content-Length: #{json_message.bytesize}\r\n\r\n#{json_message}")
      end
    end
  end
end
