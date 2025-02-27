# typed: true
# frozen_string_literal: true

require "json"

module RubyLsp
  module TestReporter
    class << self
      #: (id: String, uri: URI::Generic) -> void
      def start_test(id:, uri:)
        result = {
          event: "start",
          id: id,
          uri: uri.to_s,
        }
        send_message(result)
      end

      #: (id: String, uri: URI::Generic) -> void
      def record_pass(id:, uri:)
        result = {
          event: "pass",
          id: id,
          uri: uri.to_s,
        }
        send_message(result)
      end

      #: (id: String, type: untyped, message: String, uri: URI::Generic) -> void
      def record_fail(id:, type:, message:, uri:)
        result = {
          event: "fail",
          id: id,
          type: type,
          message: message,
          uri: uri.to_s,
        }
        send_message(result)
      end

      #: (id: String, message: String?, uri: URI::Generic) -> void
      def record_skip(id:, message:, uri:)
        result = {
          event: "skip",
          id: id,
          message: message,
          uri: uri.to_s,
        }
        send_message(result)
      end

      #: (id: String, message: String?, uri: String) -> void
      def record_error(id:, message:, uri:)
        result = {
          event: "error",
          id: id,
          message: message,
          uri: uri.to_s,
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
