require 'minitest/autorun'

require_relative 'promise'

class InnerClass
  attr_reader :v

  def initialize(v)
    @v = v
  end

  def marshal_dump
    [@v]
  end

  def marshal_load(custom_struct)
    @v = custom_struct[0]
  end
end

class TestPromise < Minitest::Test
  def test_marshal
    p1 = Promise.new{InnerClass.new(8)}

    dumped = Marshal.dump(p1)

    p2 = Marshal.load(dumped)

    assert_equal(p1.v, p2.v)
  end
end
