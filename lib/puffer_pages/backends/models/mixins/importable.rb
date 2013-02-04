module PufferPages
  module Backends
    module Mixins
      module Importable
        extend ActiveSupport::Concern

        module ClassMethods
          def export_json
            all
          end

          def import_destroy
            destroy_all
          end

          def import_json json
            data = json.is_a?(String) ? ActiveSupport::JSON.decode(json) : json.map(&:stringify_keys!)

            import_destroy

            data.each do |attributes|
              associations = attributes.keys.each_with_object({}) do |attribute, hsh|
                if scoped.reflect_on_association(attribute.to_sym)
                  hsh[attribute] = attributes.delete(attribute)
                end
              end

              attributes = attributes.with_indifferent_access
              record = scoped.create!(attributes) do |record|
                record.id = attributes[:id] if attributes[:id].present?
              end

              associations.each do |association, attributes|
                record.send(association).import_json(attributes)
              end
            end
          end
        end
      end
    end
  end
end
