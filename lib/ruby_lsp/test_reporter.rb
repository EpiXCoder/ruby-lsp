# typed: true
# frozen_string_literal: true

require "json"

module RubyLsp
  module TestReporter
    class << self
      #: (id: String, uri: URI::Generic) -> void
      def start_test(id:, uri:)
        result = {
          id: id,
          uri: uri.to_s,
        }
        send_message("start", result)
      end

      #: (id: String, uri: URI::Generic) -> void
      def record_pass(id:, uri:)
        result = {
          id: id,
          uri: uri.to_s,
        }
        send_message("pass", result)
      end

      #: (id: String, type: untyped, message: String, uri: URI::Generic) -> void
      def record_fail(id:, type:, message:, uri:)
        result = {
          id: id,
          type: type,
          message: message,
          uri: uri.to_s,
        }
        send_message("fail", result)
      end

      #: (id: String, message: String?, uri: URI::Generic) -> void
      def record_skip(id:, message:, uri:)
        result = {
          id: id,
          message: message,
          uri: uri.to_s,
        }
        send_message("skip", result)
      end

      #: (id: String, message: String?, uri: String) -> void
      def record_error(id:, message:, uri:)
        result = {
          id: id,
          message: message,
          uri: uri.to_s,
        }
        send_message("error", result)
      end

      private

      def send_message(method_name, params)
        json_message = { method: method_name, params: params }.to_json
        $stdout.write("Content-Length: #{json_message.bytesize}\r\n\r\n#{json_message}")
      end
    end
  end
end
