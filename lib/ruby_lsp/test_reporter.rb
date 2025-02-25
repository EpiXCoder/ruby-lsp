# typed: strict
# frozen_string_literal: true

require "json"

module RubyLsp
  class TestReporter
    extend T::Sig

    #: (?io: IO) -> void
    def initialize(io: $stdout)
      @io = io
    end

    #: (id: String, file: String) -> void
    def before_test(id:, file:)
      result = {
        event: "before_test",
        id: id,
        file: file,
      }
      send_message(result)
    end

    #: (id: String, file: String) -> void
    def after_test(id:, file:)
      result = {
        event: "after_test",
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
        type: type,
        message: message,
        id: id,
        file: file,
      }
      send_message(result)
    end

    #: (id: String, message: String?, file: String) -> void
    def record_skip(id:, message:, file:)
      result = {
        event: "skip",
        message: message,
        id: id,
        file: file,
      }
      send_message(result)
    end

    #: (Hash[Symbol, untyped] result) -> void
    def send_message(result)
      io.puts result.to_json
      io.flush
    end

    private

    #: IO
    attr_reader :io
  end
end
