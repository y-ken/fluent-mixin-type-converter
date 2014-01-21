require 'helper'

class TypeConverterMixinTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    tag                log.${tag}
    remove_tag_prefix  apache.
    types  code:integer,response_time:float
  ]

  def create_driver(conf=CONFIG,tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::TypeConverterMixinOutput, tag).configure(conf)
  end

  def test_configure
    assert_raise(Fluent::ConfigError) {
      d = create_driver('')
    }
    assert_raise(Fluent::ConfigError) {
      d = create_driver('unknown_keys')
    }
    d = create_driver(CONFIG)
    puts d.instance.inspect
    assert_equal 'code:integer,response_time:float', d.instance.config['types']
  end

  def test_emit
    d1 = create_driver(CONFIG, 'apache.access')
    d1.run do
      d1.emit({
        'code' => '200',
        'response_time' => '0.03'
      })
    end
    emits = d1.emits
    assert_equal 1, emits.length
    p emits[0]
    assert_equal 'log.access', emits[0][0] # tag
    assert_equal 200, emits[0][2]['code']
    assert_equal 0.03, emits[0][2]['response_time']
  end

  def test_emit_with_custom_delimiter
    d1 = create_driver(%[
      tag    test.message
      types  code:integer|response_time:float
      types_delimiter       |
      types_label_delimiter :
    ], 'apache.access')
    d1.run do
      d1.emit({
        'code' => '200',
        'response_time' => '0.03'
      })
    end
    emits = d1.emits
    assert_equal 1, emits.length
    p emits[0]
    assert_equal 'test.message', emits[0][0] # tag
    assert_equal 200, emits[0][2]['code']
    assert_equal 0.03, emits[0][2]['response_time']
  end

  def test_emit_all_types
    d1 = create_driver(%[
      tag    test.message
      types  string:string,integer:integer,float:float,bool:bool,time:time,array:array
    ], 'apache.access')
    d1.run do
      d1.emit({
        'string'  => 'foo',
        'integer' => '500',
        'float'   => '0.5',
        'bool'    => 'true',
        'time'    => '2014-01-21 12:29:44 +0900',
        'array'   => 'foo,1,2.0,true'
      })
    end
    emits = d1.emits
    assert_equal 1, emits.length
    p emits[0]
    assert_equal 'test.message', emits[0][0] # tag
    assert_equal 'foo', emits[0][2]['string']
    assert_equal 500, emits[0][2]['integer']
    assert_equal 0.5, emits[0][2]['float']
    assert_equal true, emits[0][2]['bool']
    assert_equal 1390274984, emits[0][2]['time']
    assert_equal ["foo", "1", "2.0", "true"], emits[0][2]['array']
  end
end
