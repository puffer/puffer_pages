# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130118071519) do

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "layout_translations", :force => true do |t|
    t.uuid     "layout_id"
    t.string   "locale"
    t.text     "body",       :limit => 4294967295
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "layout_translations", ["id"], :name => "sqlite_autoindex_layout_translations_1", :unique => true
  add_index "layout_translations", ["layout_id"], :name => "index_layout_translations_on_layout_id"
  add_index "layout_translations", ["locale"], :name => "index_layout_translations_on_locale"

  create_table "layouts", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "layouts", ["id"], :name => "sqlite_autoindex_layouts_1", :unique => true
  add_index "layouts", ["name"], :name => "index_layouts_on_name"

  create_table "origins", :force => true do |t|
    t.string   "name"
    t.string   "host"
    t.string   "path"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "page_part_translations", :force => true do |t|
    t.uuid     "page_part_id"
    t.string   "locale"
    t.text     "body",         :limit => 4294967295
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "page_part_translations", ["id"], :name => "sqlite_autoindex_page_part_translations_1", :unique => true
  add_index "page_part_translations", ["locale"], :name => "index_page_part_translations_on_locale"
  add_index "page_part_translations", ["page_part_id"], :name => "index_page_part_translations_on_page_part_id"

  create_table "page_parts", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.uuid     "page_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "handler"
  end

  add_index "page_parts", ["id"], :name => "sqlite_autoindex_page_parts_1", :unique => true
  add_index "page_parts", ["name"], :name => "index_page_parts_on_name"
  add_index "page_parts", ["page_id"], :name => "index_page_parts_on_page_id"

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "layout_name"
    t.string   "status"
    t.uuid     "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth",       :default => 0
    t.string   "location"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.text     "locales"
  end

  add_index "pages", ["id"], :name => "sqlite_autoindex_pages_1", :unique => true
  add_index "pages", ["location"], :name => "index_pages_on_location"
  add_index "pages", ["slug"], :name => "index_pages_on_slug"

  create_table "snippet_translations", :force => true do |t|
    t.uuid     "snippet_id"
    t.string   "locale"
    t.text     "body",       :limit => 4294967295
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "snippet_translations", ["id"], :name => "sqlite_autoindex_snippet_translations_1", :unique => true
  add_index "snippet_translations", ["locale"], :name => "index_snippet_translations_on_locale"
  add_index "snippet_translations", ["snippet_id"], :name => "index_snippet_translations_on_snippet_id"

  create_table "snippets", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "snippets", ["id"], :name => "sqlite_autoindex_snippets_1", :unique => true
  add_index "snippets", ["name"], :name => "index_snippets_on_name"

end
