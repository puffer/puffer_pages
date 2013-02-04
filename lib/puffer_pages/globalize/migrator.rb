require 'globalize'

module PufferPages
  module Globalize
    class Migrator < ::Globalize::ActiveRecord::Migration::Migrator
      def create_translation_table
        connection.create_table(translations_table_name, id: false) do |t|
          t.uuid :id, primary_key: true
          t.uuid "#{table_name.sub(/^#{table_name_prefix}/, '').singularize}_id"
          t.string :locale
          fields.each do |name, options|
            if options.is_a? Hash
              t.column name, options.delete(:type), options
            else
              t.column name, options
            end
          end
          t.timestamps
        end
      end
    end
  end
end
