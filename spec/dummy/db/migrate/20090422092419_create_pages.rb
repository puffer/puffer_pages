class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :name
      t.string :slug
      t.string :location
      t.text :title
      t.text :description
      t.text :keywords
      t.string :layout_name
      t.string :status
      t.boolean :root, :default => false

      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth, :default => 0

      t.timestamps
    end

    add_index :pages, :slug
    add_index :pages, :location
  end

  def self.down
    drop_table :pages
  end
end
