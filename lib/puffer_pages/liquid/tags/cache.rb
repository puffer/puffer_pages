module PufferPages
  module Liquid
    module Tags

      class Cache < ::Liquid::Block
        TIME_FORMATS = {
          /\A([0-9\.]+)s?\Z/ => 1,
          /\A([0-9\.]+)m\Z/ => 60,
          /\A([0-9\.]+)h\Z/ => 60*60,
          /\A([0-9\.]+)d\Z/ => 60*60*24
        }

        def initialize(tag_name, markup, tokens)
          arguments = markup.split(?,)
          options = arguments.pop if arguments.last && arguments.last.strip =~ /(#{::Liquid::TagAttributes})/

          @arguments = arguments.map do |var|
            var.strip =~ /(#{::Liquid::QuotedFragment})/
            $1 ? $1 : nil
          end.compact

          @options = {}
          options.scan(::Liquid::TagAttributes) do |key, value|
            @options[key] = value
          end if options

          super
        end

        def render(context)
          arguments = @arguments.map { |value| context[value] }

          options = @options.each_with_object({}) do |(key, value), result|
            result[key] = context[value]
          end
          options = {
            expires_in: expires_in(options['expires_in'])
          }.reject { |k, v| v.nil? }

          key = cache_key arguments.unshift(context[:processed])

          if cache?
            cache_store.fetch(key, options) do
              super
            end
          else
            super
          end
        end

        def expires_in expiration
          fragments = expiration.to_s.split(' ').map(&:strip)
          times = fragments.map do |fragment|
            TIME_FORMATS.inject(nil) do |result, (format, multiplier)|
              break result if result
              match = fragment.match(format)
              (match[1].to_f * multiplier).round if match
            end
          end
          times.sum if times.present? && times.all?
        end

        def cache_key key
          ActiveSupport::Cache.expand_cache_key key
        end

        def cache_store
          PufferPages.cache_store
        end

        def cache?
          PufferPages.config.perform_caching && cache_store
        end
      end

    end
  end
end

Liquid::Template.register_tag('cache', PufferPages::Liquid::Tags::Cache)
