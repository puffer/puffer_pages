module PufferPages
  module Backends
    module Mixins
      module Localable
        extend ActiveSupport::Concern

        included do
          serialize :locales, Locales

          validate do
            errors[:locales] = locales.error unless locales.valid?
          end
        end

        def locales
          value = read_attribute(:locales)
          value.is_a?(Locales) ? value : Locales.new(value)
        end

        class Locales < ActiveSupport::HashWithIndifferentAccess
          def initialize source
            update (source.presence || {}).stringify_keys
            super()
          end

          def valid?
            !error
          end

          def error
            translations
          rescue ::SyntaxError => e
            e.message
          else
            false
          end

          def translations
            @translations ||= Hash[map do |(locale, yaml)|
              load_arguments = [yaml]
              load_arguments.push "<#{locale}>" if YAML.method(:load).arity == -2
              result = YAML.load yaml
              result = result.presence || {}
              raise ::SyntaxError.new("(<#{locale}>): Locale should be a hash") unless result.is_a?(Hash)
              [locale.to_sym, result.deep_symbolize_keys]
            end]
          end

          class << self
            def dump value
              value = value.is_a?(Locales) ? value : Locales.new(value)
              value ? YAML.dump(value.to_hash) : nil
            end

            def load value
              return unless value
              value = YAML.load(value) if value.is_a?(String)
              value.is_a?(Locales) ? value : Locales.new(value)
            end
          end
        end
      end
    end
  end
end
