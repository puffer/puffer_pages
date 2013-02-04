# This migration comes from puffer_pages (originally 20090504132337)
class CreatePageParts < ActiveRecord::Migration
  def self.up
    create_table :page_parts do |t|
      t.string :name
      t.text :body
      t.integer :page_id

      t.timestamps
    end

    add_index :page_parts, :name
    add_index :page_parts, :page_id
  end

  def self.down
    drop_table :page_parts
  end
end
