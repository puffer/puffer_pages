module PufferPages
  module Backends
    module Mixins
      module Renderable
        extend ActiveSupport::Concern
        extend ::NewRelic::Agent::MethodTracer if defined? ::NewRelic

        def template
          @template ||= ::Liquid::Template.parse(self)
        end

        private


        # Method gets some arguments and returns source, context and additional
        # depends on arguments properties
        # Ex.
        #  normalize_render_options Object, Liquid::Context, Hash
        # => Object, Liquid::Context, Hash
        #
        #  normalize_render_options Liquid::Context, Hash
        # => nil, Liquid::Context, Hash
        #
        #  normalize_render_options Object, Hash1, Hash2
        # => Object, Hash1, Hash2
        #
        #  normalize_render_options Hash1, Hash2
        # => nil, Hash1, Hash2
        #
        #  normalize_render_options Liquid::Context
        # => nil, Liquid::Context, {}
        #
        #  normalize_render_options Hash
        # => nil, Hash, {}
        #
        #  normalize_render_options Object, Hash
        # => Object, Hash, {}
        #
        #  normalize_render_options Object, Liquid::Context
        # => Object, Liquid::Context, {}
        #
        #  normalize_render_options
        # => nil, {}, {}
        #
        #  normalize_render_options Object, Liquid::Contex, Hash, Hash
        # => raise ArgumentError
        def normalize_render_options *args
          source, context, additional = nil, {}, {}
          context_or_additional = args.extract_options!
          case args.count
          when 0
            context = context_or_additional
          when 1
            case args.first
            when ::Liquid::Context, ::Hash
              context = args.first
              additional = context_or_additional
            else
              source = args.first
              context = context_or_additional
            end
          when 2
            source, context = *args
            additional = context_or_additional
          else
            raise ArgumentError.new("Wrong number of arguments (#{args.count.next} for 0-3)")
          end

          return source, merge_context(context, additional)
        end

        def merge_context context, additional
          additional = normalize_context_options(additional)

          if context.is_a?(::Liquid::Context)
            context.merge additional[:drops]
            context.merge additional[:environment]
            context.registers.merge! additional[:registers]
          else
            context = normalize_context_options(context)
            context[:drops].merge! additional[:drops]
            context[:environment].merge! additional[:environment]
            context[:registers].merge! additional[:registers]
          end

          context
        end

        def normalize_context_options options
          detector = [:drops, :environment, :registers]
          if options.is_a?(Hash) && (options.keys - detector == [])
            drops = options[:drops] || {}
            environment = options[:environment] || {}
            registers = options[:registers] || {}
          else
            drops = options
            environment = {}
            registers = {}
          end
          {
            drops: drops.stringify_keys,
            environment: environment.symbolize_keys,
            registers: registers.symbolize_keys
          }
        end

        def render_template source, context = {}, additional = {}
          self.class.trace_execution_scoped(["Custom/render_template/#{self.name.try(:underscore) || 'other'}"]) do

            template = source.respond_to?(:template) ? source.template : ::Liquid::Template.parse(source)
            context = merge_context(context, additional)

            if context.is_a?(::Liquid::Context)
              instrument_render! context do
                template.send(render_method, context)
              end
            else
              tracker = PufferPages::Liquid::Tracker.new
              context = merge_context(context, registers: {
                                        :file_system => PufferPages::Liquid::FileSystem.new,
                                        :tracker => tracker
                                      })

              instrument_render! context do
                tracker.cleanup template.send(render_method,
                                              context[:drops].merge!(context[:environment]),
                                              registers: context[:registers])
              end
            end
          end
        end

        def instrument_render! context, additional = {}, &block
          context = merge_context(context, additional) if additional.present?

          payload = { subject: self }
          if context.is_a?(::Liquid::Context)
            drops = context.scopes.each_with_object({}) { |scope, hash| hash.merge! scope }
            payload.merge! drops: drops, registers: context.registers
          else
            payload.merge! drops: context[:drops], registers: context[:registers]
          end

          ActiveSupport::Notifications.instrument(instrument_name, payload, &block)
        end

        def instrument_name
          "render_#{self.class.to_s.demodulize.underscore}.puffer_pages"
        end

        def render_method
          PufferPages.config.raise_errors ? 'render!' : 'render'
        end
      end
    end
  end
end
