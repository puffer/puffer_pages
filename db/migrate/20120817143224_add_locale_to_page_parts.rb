class AddLocaleToPageParts < ActiveRecord::Migration
  def change
    add_column :page_parts, :locale, :string
  end
end
