module PufferPages
  module Backends
    module Mixins
      module Translatable
        extend ActiveSupport::Concern

        module ClassMethods
          def translatable *fields
            if PufferPages.localize
              translates *fields, fallbacks_for_empty_translations: true
              translation_class.send(:include, ActiveUUID::UUID)

              def self.globalize_migrator
                @globalize_migrator ||= PufferPages::Globalize::Migrator.new(self)
              end

              define_method :cache_translations do
                translations.with_locale(Globalize.fallbacks).each do |translation|
                  translation_caches[translation.locale.to_sym] = translation
                end
              end

              fields.each do |field|
                define_method "#{field}_translations" do
                  result = translations.each_with_object(HashWithIndifferentAccess.new) do |translation, result|
                    result[translation.locale] = translation.send(field)
                  end
                  globalize.stash.keys.each_with_object(result) do |locale, result|
                    result[locale] = globalize.stash.read(locale, field) if globalize.stash.contains?(locale, field)
                  end
                end

                define_method "#{field}_translations=" do |value|
                  value.each do |(locale, value)|
                    write_attribute(field, value, locale: locale)
                  end
                end
              end

              define_method :serializable_hash_with_translations do |options = nil|
                options ||= {}
                except = Array.wrap(options[:except])
                options[:except] = except +
                  self.class.translated_attribute_names.map(&:to_s)
                methods = Array.wrap(options[:methods])
                options[:methods] = methods +
                  self.class.translated_attribute_names.map { |name| "#{name}_translations" }
                serializable_hash_without_translations options
              end

              alias_method_chain :serializable_hash, :translations
            end
          end
        end
      end
    end
  end
end
