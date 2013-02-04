module PufferPages
  module Migrations
    def self.create_translation_tables! options = {}
      unless PufferPages.localize
        puts "WARN: Translation tables creation skip. Set `PufferPages.localize = true` to perform it"
        return
      end
      options = options.reverse_merge migrate_data: true

      [PufferPages::PagePart, PufferPages::Layout, PufferPages::Snippet].each do |model|
        model.create_translation_table!({
          body: { type: :text }
        }, options)
        puts "-- Created translation table for #{model} with #{options}"
      end
    end

    def self.drop_translation_tables! options = {}
      unless PufferPages.localize
        puts "WARN: Translation tables dropping skip. Set `PufferPages.localize = true` to perform it"
        return
      end
      options = options.reverse_merge migrate_data: true

      [PufferPages::PagePart, PufferPages::Layout, PufferPages::Snippet].each do |model|
        model.drop_translation_table! options
        puts "-- Dropped translation table for #{model} with #{options}"
      end
    end
  end
end
