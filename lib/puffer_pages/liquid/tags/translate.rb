module PufferPages
  module Liquid
    module Tags

      class Translate < ::Liquid::Tag
        Syntax = /^(#{::Liquid::QuotedFragment})/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @key = $1
          else
            raise SyntaxError.new("Syntax Error in 'translate' - Valid syntax: translate key")
          end

          @options = {}
          markup.scan(::Liquid::TagAttributes) do |key, value|
            @options[key.to_sym] = value
          end

          super
        end

        def render(context)
          key = context[@key]
          options = @options.each_with_object({}) do |(name, value), result|
            result[name] = context[value] unless I18n::RESERVED_KEYS.include?(name)
          end
          processed = context[:processed]

          if options[:count].is_a?(String)
            begin
              options[:count] = (options[:count] =~ /\./ ? Float(options[:count]) : Integer(options[:count]))
            rescue ArgumentError
            end
          end

              if processed && key.first == '.'
                default = i18n_defaults(processed, key.last(-1))
                options.merge!(:default => default) if default.any?
                I18n.translate i18n_key(processed, key.last(-1)), options
              else
                I18n.translate key, options
              end
        end

        def i18n_key(processed, key)
          array_to_key processed.i18n_scope, key
        end

        def i18n_defaults(processed, key)
          processed.i18n_defaults.map { |default| array_to_key default, key }
        end

        def array_to_key *array
          array.flatten.map { |segment| segment.to_s.tr(?., ?/) }.join(?.).to_sym
        end

        def blank?
          false
        end
      end

    end
  end
end

Liquid::Template.register_tag('translate', PufferPages::Liquid::Tags::Translate)
Liquid::Template.register_tag('t', PufferPages::Liquid::Tags::Translate)
