## Fluent::Mixin::TypeConverter [![Build Status](https://travis-ci.org/y-ken/fluent-mixin-type-converter.png?branch=master)](https://travis-ci.org/y-ken/fluent-mixin-type-converter)

## Overview

Fluentd mixin plugin to provides type conversion function as like as in_tail plugin. It acts calling [Fluent::TextParser::TypeConverter](https://github.com/fluent/fluentd/blob/master/lib/fluent/parser.rb) as mixin. It will let you get easy to implement type conversion for your own plugins.

## Function

It supportes these type conversion.

- string
- integer
- float
- bool
- time
- array

#### Option

* `types_delimiter`  
[default] `,`

* `types_label_delimiter`  
[default] `:`

## Configuration

Adding this mixin plugin, it will enabled to use these type conversion in your plugins.

```xml
# input plugin example
<source>
  type   foo_bar
  tag    test.message
  
  # type conversion with this rule before emit.
  types  member_id:int,temperature:float
</source>
```

```xml
# output plugin example
<match test.foo>
  type   foo_bar
  tag    test.message

  # type conversion with this rule before emit.
  types  member_id:int,temperature:float
</match>
```

Another examples are written in [unit test](https://github.com/y-ken/fluent-mixin-type-converter/blob/master/test/mixin/test_type_converter).

## Usage

#### 1. edit gemspec

add dependency for .gemspec file like below. For more detail, see [gemspec example](https://github.com/y-ken/fluent-plugin-watch-process/blob/master/fluent-plugin-watch-process.gemspec)

```ruby
spec.add_runtime_dependency "fluent-mixin-type-converter"
```

#### 2. activate fluent-mixin-type-converter for your plugin

It is the instruction in the case of adding `fluent-plugin-foobar`.

```
$ cd fluent-plugin-foobar
$ vim fluent-plugin-foobar.gemspec # edit gemspec
$ bundle install --path vendor/bundle # or just type `bundle install`
```

#### 3. edit your plugin to implement

It is a quick guide to enable your plugin to use TypeConverter Mixin.  
The key points of basic implmentation is just like below.

* add `require 'fluent/mixin/type_converter'` at the top of source
* in the case of output plugin, add `include Fluent::HandleTagNameMixin` (recommend)  
this is required if you will use kind of 'remove_tag_prefix' option together
* add `include Fluent::Mixin::TypeConverter` in intput/output class after HandleTagNameMixin
* add `emit_tag = tag.dup` and `filter_record(emit_tag, time, record)` before `Engine.emit`

##### implement example for input plugin

```ruby
require 'fluent/mixin/type_converter'

module Fluent
  class FooBarInput < Fluent::Input
    Plugin.register_input('foo_bar', self)

    # ...snip...
    
    include Fluent::Mixin::TypeConverter
    config_param :types, :string, :default => nil
    config_param :types_delimiter, :string, :default => ','
    config_param :types_label_delimiter, :string, :default => ':'

    # ...snip...

    def emit_message(tag, message)
      emit_tag = tag.dup
      filter_record(emit_tag, Engine.now, message)
      Engine.emit(emit_tag, Engine.now, message)
    end

    # ...snip...

  end
end
```

##### implement example for output plugin

```ruby
require 'fluent/mixin/type_converter'

class Fluent
  class FooBarOutput < Fluent::Output
    Fluent::Plugin.register_output('foo_bar', self)

    # ...snip...

    include Fluent::Mixin::TypeConverter
    config_param :types, :string, :default => nil
    config_param :types_delimiter, :string, :default => ','
    config_param :types_label_delimiter, :string, :default => ':'

    # ...snip...

    def emit(tag, es, chain)
      es.each do |time, record|
        emit_tag = tag.dup
        filter_record(emit_tag, time, record)
        Fluent::Engine.emit(emit_tag, time, record)
      end
      chain.next
    end

    # ...snip...

  end
end
```

## Case Study

These cool plugins are using this mixin!

* [fluent-plugin-watch-process](https://github.com/y-ken/fluent-plugin-watch-process/)

## TODO

Pull requests are very welcome!!

## Copyright

Copyright © 2014- Kentaro Yoshida ([@yoshi_ken](https://twitter.com/yoshi_ken))

## License

Apache License, Version 2.0
