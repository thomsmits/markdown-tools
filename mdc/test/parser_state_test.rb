require 'minitest/autorun'
require_relative '../lib/parsing/parser_state'

##
# Tests for the class ParserState
class ParserStateTest < Minitest::Test
  ##
  # Test for the automatic methods regarding the state
  def test_state_methods
    ps = Parsing::ParserState.new(nil, '', 1, :STATE_1, :STATE_2, :STATE_3)

    assert(ps.state_1?)

    ps.state_2!
    assert(!ps.state_1?)
    assert(!ps.state_3?)
    assert(ps.state_2?)

    ps.state_3!
    assert(!ps.state_1?)
    assert(!ps.state_2?)
    assert(ps.state_3?)

    assert_raises(NoMethodError) { ps.state_1 }
    assert_raises(NoMethodError) { ps.state_2 }
    assert_raises(NoMethodError) { ps.state_3 }
    assert_raises(NoMethodError) { ps.state_4! }
    assert_raises(NoMethodError) { ps.state_4? }
    assert_raises(NoMethodError) { ps.statex }
  end

  # Test correct handling of missing methods
  def test_method_missing
    ps = Parsing::ParserState.new(nil, '', 1, :STATE_1, :STATE_2, :STATE_3)
    assert(ps.respond_to? :state_1?)
    assert(ps.respond_to? :state_2?)
    assert(ps.respond_to? :state_3?)
    assert(ps.respond_to? :state_1!)
    assert(ps.respond_to? :state_2!)
    assert(ps.respond_to? :state_3!)
    assert(!(ps.respond_to? :state_1))
    assert(!(ps.respond_to? :state_2))
    assert(!(ps.respond_to? :state_3))
    assert(!(ps.respond_to? :state_ex))
  end
end
