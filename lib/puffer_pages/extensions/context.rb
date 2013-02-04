module PufferPages
  module Extensions
    module Liquid
      module Context
        extend ActiveSupport::Concern

        included do
          alias_method_chain :resolve, :interpolation
        end

        def resolve_with_interpolation key
          if key.is_a? Symbol
            scope = @scopes.detect { |s| s.key? key }
            scope ||= @environments.detect { |s| s.key? key }
            scope[key] if scope
          else
            resolved = resolve_without_interpolation key
            if resolved.is_a?(String) && key =~ /^"(.*)"$/
              resolved.gsub!(/\#\{(.*?)\}/) do
                ::Liquid::Variable.new($1).render(self)
              end
            end
            resolved
          end
        end
      end
    end
  end
end

Liquid::Context.send :include, PufferPages::Extensions::Liquid::Context
