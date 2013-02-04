# This migration comes from puffer_pages (originally 20130118064524)
class AddLocalesToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :locales, :text
  end

  def self.down
    remove_column :pages, :locales
  end
end
