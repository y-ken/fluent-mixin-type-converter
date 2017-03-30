require 'fluent/mixin/rewrite_tag_name'

class Fluent::TypeConverterMixinOutput < Fluent::Output
  Fluent::Plugin.register_output('type_converter_mixin', self)

  config_param :tag, :string, :default => nil
  config_param :types, :string, :default => nil
  config_param :types_delimiter, :string, :default => ','
  config_param :types_label_delimiter, :string, :default => ':'

  include Fluent::HandleTagNameMixin
  include Fluent::Mixin::RewriteTagName
  include Fluent::Mixin::TypeConverter

  def configure(conf)
    super

    if ( !@tag && !@remove_tag_prefix && !@remove_tag_suffix && !@add_tag_prefix && !@add_tag_suffix )
      raise Fluent::ConfigError, "RewriteTagNameMixin: missing remove_tag_prefix, remove_tag_suffix, add_tag_prefix or add_tag_suffix."
    end
  end

  # Define `router` method of v0.12 to support v0.10 or earlier
  unless method_defined?(:router)
    define_method("router") { Fluent::Engine }
  end

  def emit(tag, es, chain)
    es.each do |time, record|
      emit_tag = tag.dup
      filter_record(emit_tag, time, record)
      router.emit(emit_tag, time, record)
    end
    chain.next
  end
end
