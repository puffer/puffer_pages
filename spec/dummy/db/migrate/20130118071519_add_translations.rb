class AddTranslations < ActiveRecord::Migration
  def self.up
    PufferPages::Migrations.create_translation_tables!
  end

  def self.down
    PufferPages::Migrations.drop_translation_table!
  end
end
