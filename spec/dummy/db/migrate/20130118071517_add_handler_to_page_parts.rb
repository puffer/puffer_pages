# This migration comes from puffer_pages (originally 20130110144030)
class AddHandlerToPageParts < ActiveRecord::Migration
  def self.up
    add_column :page_parts, :handler, :string
  end

  def self.down
    remove_column :page_parts, :handler
  end
end
