# typed: true
# frozen_string_literal: true

require "test_helper"

module RubyLsp
  class ResolveTestCommandsTest < Minitest::Test
    def test_resolve_test_command_specific_examples
      with_server do |server|
        server.process_message({
          id: 1,
          method: "rubyLsp/resolveTestCommands",
          params: {
            items: [
              {
                id: "ServerTest",
                uri: "file:///test/server_test.rb",
                label: "ServerTest",
                range: {
                  start: { line: 0, character: 0 },
                  end: { line: 30, character: 3 },
                },
                tags: ["minitest", "test_group"],
                children: [
                  {
                    id: "ServerTest#test_server",
                    uri: "file:///test/server_test.rb",
                    label: "test_server",
                    range: {
                      start: { line: 1, character: 2 },
                      end: { line: 10, character: 3 },
                    },
                    tags: ["minitest"],
                    children: [],
                  },
                ],
              },
              {
                id: "StoreTest",
                uri: "file:///test/store_test.rb",
                label: "StoreTest",
                range: {
                  start: { line: 0, character: 0 },
                  end: { line: 30, character: 3 },
                },
                tags: ["minitest", "test_group"],
                children: [
                  {
                    id: "StoreTest#test_store",
                    uri: "file:///test/store_test.rb",
                    label: "test_store",
                    range: {
                      start: { line: 1, character: 2 },
                      end: { line: 10, character: 3 },
                    },
                    tags: ["minitest"],
                    children: [],
                  },
                ],
              },
            ],
          },
        })

        result = server.pop_response.response
        assert_equal(
          [
            "bundle exec ruby -Itest /test/server_test.rb --name \"/^ServerTest#test_server$/\"",
            "bundle exec ruby -Itest /test/store_test.rb --name \"/^StoreTest#test_store$/\"",
          ],
          result[:commands],
        )
      end
    end

    def test_resolve_test_command_group_mixed_with_examples
      with_server do |server|
        server.process_message({
          id: 1,
          method: "rubyLsp/resolveTestCommands",
          params: {
            items: [
              {
                id: "ServerTest",
                uri: "file:///test/server_test.rb",
                label: "ServerTest",
                range: {
                  start: { line: 0, character: 0 },
                  end: { line: 30, character: 3 },
                },
                tags: ["minitest", "test_group"],
                children: [],
              },
              {
                id: "StoreTest",
                uri: "file:///test/store_test.rb",
                label: "StoreTest",
                range: {
                  start: { line: 0, character: 0 },
                  end: { line: 30, character: 3 },
                },
                tags: ["minitest", "test_group"],
                children: [
                  {
                    id: "StoreTest#test_store",
                    uri: "file:///test/store_test.rb",
                    label: "test_store",
                    range: {
                      start: { line: 1, character: 2 },
                      end: { line: 10, character: 3 },
                    },
                    tags: ["minitest"],
                    children: [],
                  },
                ],
              },
            ],
          },
        })

        result = server.pop_response.response
        assert_equal(
          [
            "bundle exec ruby -Itest /test/server_test.rb --name \"/^ServerTest(#|::)/\"",
            "bundle exec ruby -Itest /test/store_test.rb --name \"/^StoreTest#test_store$/\"",
          ],
          result[:commands],
        )
      end
    end

    def test_resolve_test_command_multiple_examples_from_same_group
      with_server do |server|
        server.process_message({
          id: 1,
          method: "rubyLsp/resolveTestCommands",
          params: {
            items: [
              {
                id: "ServerTest",
                uri: "file:///test/server_test.rb",
                label: "ServerTest",
                range: {
                  start: { line: 0, character: 0 },
                  end: { line: 30, character: 3 },
                },
                tags: ["minitest", "test_group"],
                children: [
                  {
                    id: "ServerTest#test_server",
                    uri: "file:///test/server_test.rb",
                    label: "test_server",
                    range: {
                      start: { line: 1, character: 2 },
                      end: { line: 10, character: 3 },
                    },
                    tags: ["minitest"],
                    children: [],
                  },
                  {
                    id: "ServerTest#test_server_again",
                    uri: "file:///test/server_test.rb",
                    label: "test_server_again",
                    range: {
                      start: { line: 12, character: 2 },
                      end: { line: 30, character: 3 },
                    },
                    tags: ["minitest"],
                    children: [],
                  },
                ],
              },
            ],
          },
        })

        result = server.pop_response.response
        assert_equal(
          [
            "bundle exec ruby -Itest /test/server_test.rb --name \"/^ServerTest#(test_server|test_server_again)$/\"",
          ],
          result[:commands],
        )
      end
    end

    def test_resolve_test_command_entire_files
      with_server do |server|
        server.process_message({
          id: 1,
          method: "rubyLsp/resolveTestCommands",
          params: {
            items: [
              {
                id: "file:///test/server_test.rb",
                uri: "file:///test/server_test.rb",
                label: "/test/server_test.rb",
                tags: ["test_file"],
                children: [],
              },
              {
                id: "file:///test/store_test.rb",
                uri: "file:///test/store_test.rb",
                label: "/test/store_test.rb",
                tags: ["test_file"],
                children: [],
              },
            ],
          },
        })

        result = server.pop_response.response
        assert_equal(
          [
            "bundle exec ruby -Itest /test/server_test.rb /test/store_test.rb",
          ],
          result[:commands],
        )
      end
    end

    def test_resolve_test_command_entire_directories
      with_server do |server|
        server.process_message({
          id: 1,
          method: "rubyLsp/resolveTestCommands",
          params: {
            items: [
              {
                id: "file:///other/test",
                uri: "file:///other/test",
                label: "/other/test",
                tags: ["test_dir"],
                children: [],
              },
              {
                id: "file:///test/server_test.rb",
                uri: "file:///test/server_test.rb",
                label: "/test/server_test.rb",
                tags: ["test_file"],
                children: [],
              },
              {
                id: "file:///test/store_test.rb",
                uri: "file:///test/store_test.rb",
                label: "/test/store_test.rb",
                tags: ["test_file"],
                children: [],
              },
            ],
          },
        })

        result = server.pop_response.response
        assert_equal(
          [
            "bundle exec ruby -Itest /other/test/**/* /test/server_test.rb /test/store_test.rb",
          ],
          result[:commands],
        )
      end
    end

    def test_resolve_test_command_multiple_test_groups
      with_server do |server|
        server.process_message({
          id: 1,
          method: "rubyLsp/resolveTestCommands",
          params: {
            items: [
              {
                id: "ServerTest",
                uri: "file:///test/server_test.rb",
                label: "ServerTest",
                range: {
                  start: { line: 0, character: 0 },
                  end: { line: 30, character: 3 },
                },
                tags: ["minitest", "test_group"],
                children: [],
              },
              {
                id: "OtherServerTest",
                uri: "file:///test/server_test.rb",
                label: "OtherServerTest",
                range: {
                  start: { line: 32, character: 0 },
                  end: { line: 60, character: 3 },
                },
                tags: ["minitest", "test_group"],
                children: [],
              },
            ],
          },
        })

        result = server.pop_response.response
        assert_equal(
          [
            "bundle exec ruby -Itest /test/server_test.rb --name \"/(^ServerTest(#|::)|^OtherServerTest(#|::))/\"",
          ],
          result[:commands],
        )
      end
    end

    def test_resolve_test_command_complex_case
      with_server do |server|
        server.process_message({
          id: 1,
          method: "rubyLsp/resolveTestCommands",
          params: {
            items: [
              {
                id: "ServerTest",
                uri: "file:///test/server_test.rb",
                label: "ServerTest",
                range: {
                  start: { line: 0, character: 0 },
                  end: { line: 30, character: 3 },
                },
                tags: ["minitest", "test_group"],
                children: [
                  {
                    id: "ServerTest#test_server",
                    uri: "file:///test/server_test.rb",
                    label: "test_server",
                    range: {
                      start: { line: 1, character: 2 },
                      end: { line: 10, character: 3 },
                    },
                    tags: ["minitest"],
                    children: [],
                  },
                  {
                    id: "ServerTest#test_server_again",
                    uri: "file:///test/server_test.rb",
                    label: "test_server_again",
                    range: {
                      start: { line: 1, character: 2 },
                      end: { line: 10, character: 3 },
                    },
                    tags: ["minitest"],
                    children: [],
                  },
                ],
              },
              {
                id: "OtherServerTest",
                uri: "file:///test/server_test.rb",
                label: "OtherServerTest",
                range: {
                  start: { line: 0, character: 0 },
                  end: { line: 30, character: 3 },
                },
                tags: ["minitest", "test_group"],
                children: [],
              },
              {
                id: "StoreTest",
                uri: "file:///test/store_test.rb",
                label: "StoreTest",
                range: {
                  start: { line: 0, character: 0 },
                  end: { line: 30, character: 3 },
                },
                tags: ["minitest", "test_group"],
                children: [
                  {
                    id: "StoreTest#test_store",
                    uri: "file:///test/store_test.rb",
                    label: "test_store",
                    range: {
                      start: { line: 1, character: 2 },
                      end: { line: 10, character: 3 },
                    },
                    tags: ["minitest"],
                    children: [],
                  },
                ],
              },
            ],
          },
        })

        result = server.pop_response.response
        assert_equal(
          [
            "bundle exec ruby -Itest /test/server_test.rb --name " \
              "\"/(^ServerTest#(test_server|test_server_again)$|^OtherServerTest(#|::))/\"",
            "bundle exec ruby -Itest /test/store_test.rb --name \"/^StoreTest#test_store$/\"",
          ],
          result[:commands],
        )
      end
    end

    def test_resolve_test_command_examples_with_dynamic_references
      with_server do |server|
        server.process_message({
          id: 1,
          method: "rubyLsp/resolveTestCommands",
          params: {
            items: [
              {
                id: "<dynamic_reference>::ServerTest",
                uri: "file:///test/server_test.rb",
                label: "<dynamic_reference>::ServerTest",
                range: {
                  start: { line: 0, character: 0 },
                  end: { line: 30, character: 3 },
                },
                tags: ["minitest", "test_group"],
                children: [
                  {
                    id: "<dynamic_reference>::ServerTest#test_server",
                    uri: "file:///test/server_test.rb",
                    label: "test_server",
                    range: {
                      start: { line: 1, character: 2 },
                      end: { line: 10, character: 3 },
                    },
                    tags: ["minitest"],
                    children: [],
                  },
                ],
              },
              {
                id: "<dynamic_reference>::StoreTest",
                uri: "file:///test/store_test.rb",
                label: "<dynamic_reference>::StoreTest",
                range: {
                  start: { line: 0, character: 0 },
                  end: { line: 30, character: 3 },
                },
                tags: ["minitest", "test_group"],
                children: [],
              },
            ],
          },
        })

        result = server.pop_response.response
        assert_equal(
          [
            "bundle exec ruby -Itest /test/server_test.rb --name \"/^.\\*::ServerTest#test_server$/\"",
            "bundle exec ruby -Itest /test/store_test.rb --name \"/^.\\*::StoreTest(#|::)/\"",
          ],
          result[:commands],
        )
      end
    end
  end
end
