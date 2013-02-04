# This migration comes from puffer_pages (originally 20120812100913)
class CreateOrigins < ActiveRecord::Migration
  def self.up
    create_table :origins do |t|
      t.string :name
      t.string :host
      t.string :path
      t.string :token

      t.timestamps
    end
  end

  def self.down
    drop_table :origins
  end
end
