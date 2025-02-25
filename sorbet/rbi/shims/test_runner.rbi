# typed: true

module Test
  module Unit
    module RubyLsp
      class TestRunner < ::Test::Unit::UI::TestRunner
        include Kernel # for `method`
      end
    end
  end
end
