class CreateLayouts < ActiveRecord::Migration
  def self.up
    create_table :layouts do |t|
      t.string :name
      t.text :body

      t.timestamps
    end

    add_index :layouts, :name
  end

  def self.down
    drop_table :layouts
  end
end
