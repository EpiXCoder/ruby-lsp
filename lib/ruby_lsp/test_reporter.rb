# typed: strict
# frozen_string_literal: true

require "json"

module RubyLsp
  class OutputWriter
    extend T::Helpers
    abstract!

    #: (io: IO?) -> void
    def initialize(io: $stdout)
      @io = T.let(io, IO)
    end

    # @abstract
    #: (Hash[Symbol, untyped] result) -> void
    def write(result); end
  end

  class PlainWriter < OutputWriter
    # @override
    #: (Hash[Symbol, untyped] result) -> void
    def write(result)
      @io.puts result.to_json
      @io.flush
    end
  end

  class JsonRPCWriter < OutputWriter
    # @override
    #: (Hash[Symbol, untyped] result) -> void
    def write(result)
      json_message = result.to_json
      @io.write("Content-Length: #{json_message.bytesize}\r\n\r\n#{json_message}")
    end
  end

  class TestReporter
    extend T::Sig

    #: (io: IO?, output_writer: singleton(OutputWriter)) -> void
    def initialize(io: $stdout, output_writer: PlainWriter)
      @io = io
      @output_writer = T.let(output_writer.new(io: io), OutputWriter)
    end

    #: (id: String, file: String) -> void
    def start_test(id:, file:)
      result = {
        event: "start",
        id: id,
        file: file,
      }
      output_writer.write(result)
    end

    #: (id: String, file: String) -> void
    def record_pass(id:, file:)
      result = {
        event: "pass",
        id: id,
        file: file,
      }
      output_writer.write(result)
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
      output_writer.write(result)
    end

    #: (id: String, message: String?, file: String) -> void
    def record_skip(id:, message:, file:)
      result = {
        event: "skip",
        id: id,
        message: message,
        file: file,
      }
      output_writer.write(result)
    end

    #: (id: String, message: String?, file: String) -> void
    def record_error(id:, message:, file:)
      result = {
        event: "error",
        id: id,
        message: message,
        file: file,
      }
      output_writer.write(result)
    end

    #: (id: String, output: String) -> void
    def append_output(id:, output:)
      result = {
        event: "append_output",
        id: id,
        output: output,
      }
      output_writer.write(result)
    end

    private

    #: IO?
    attr_reader :io

    #: OutputWriter
    attr_reader :output_writer
  end
end
