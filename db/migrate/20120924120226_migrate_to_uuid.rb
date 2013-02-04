class PreviousPage < ActiveRecord::Base
  acts_as_nested_set
  has_many :page_parts, :class_name => '::PreviousPagePart', :inverse_of => :page, :foreign_key => :page_id
  def import_attributes
    attributes.except *%w(id parent_id lft rgt depth location title description keywords)
  end
end

class PreviousPagePart < ActiveRecord::Base
  belongs_to :page, :class_name => '::PreviousPage', :inverse_of => :page_parts
  def import_attributes
    attributes.except *%w(id page_id)
  end
end

class PreviousLayout < ActiveRecord::Base
  def import_attributes
    attributes.except *%w(id)
  end
end

class PreviousSnippet < ActiveRecord::Base
  def import_attributes
    attributes.except *%w(id)
  end
end

class MigrateToUuid < ActiveRecord::Migration
  def up
    [:pages, :page_parts, :layouts, :snippets].each do |table|
      ActiveRecord::Base.connection.indexes(table).each do |index|
        remove_index table, :name => index.name
      end
      rename_table table, :"previous_#{table}"
    end

    create_table :pages, :id => false do |t|
      t.uuid       :id, :primary_key => true
      t.string     :name
      t.string     :slug
      t.string     :layout_name
      t.string     :status
      t.uuid       :parent_id
      t.integer    :lft
      t.integer    :rgt
      t.integer    :depth, :default => 0
      t.string     :location
      t.timestamps
    end

    create_table :page_parts, :id => false do |t|
      t.uuid       :id, :primary_key => true
      t.string     :name
      t.text       :body
      t.uuid       :page_id
      t.timestamps
    end

    create_table :layouts, :id => false do |t|
      t.uuid       :id, :primary_key => true
      t.string     :name
      t.text       :body
      t.timestamps
    end

    create_table :snippets, :id => false do |t|
      t.uuid       :id, :primary_key => true
      t.string     :name
      t.text       :body
      t.timestamps
    end

    add_index :pages, :slug
    add_index :pages, :location

    add_index :page_parts, :name
    add_index :page_parts, :page_id

    add_index :layouts, :name

    add_index :snippets, :name

    [PufferPages::Page, PufferPages::PagePart, PufferPages::Layout, PufferPages::Snippet,
      PreviousPage, PreviousPagePart, PreviousLayout, PreviousSnippet].each do |model|
      model.reset_column_information
    end

    puts "\nMigrating data"
    PufferPages::Page.transaction do
      import_child_pages PreviousPage.roots
      PreviousLayout.all.each { |layout| PufferPages::Layout.create!(layout.import_attributes); print '.' }
      PreviousSnippet.all.each { |snippet| PufferPages::Snippet.create!(snippet.import_attributes); print '.' }
    end
    puts "\n"

    [:pages, :page_parts, :layouts, :snippets].each do |table|
      drop_table :"previous_#{table}"
    end
  end

  def import_child_pages pages, new_parent = nil
    pages.each do |page|
      new_page = (new_parent ? new_parent.children : PufferPages::Page).create! page.import_attributes
      new_page.page_parts = page.page_parts.map do |page_part|
        print '.'
        PufferPages::PagePart.create! page_part.import_attributes
      end
      print '.'
      %w(title keywords description).each do |attribute|
        print '.'
        page_part = new_page.page_parts.detect { |page_part| page_part.name == attribute }
        if page_part
          page_part.update_attributes body: "#{page_part.body}\n--#{attribute} value--\n#{page.send(attribute)}"
        else
          new_page.page_parts.create! name: attribute, body: page.send(attribute)
        end
      end
      page.save
      import_child_pages page.children, new_page unless page.leaf?
    end
  end

  def down
    raise IrreversibleMigration
  end
end
