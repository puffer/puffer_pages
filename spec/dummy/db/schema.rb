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

ActiveRecord::Schema.define(:version => 20111117081813) do

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "layouts", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "layouts", ["name"], :name => "index_layouts_on_name"

  create_table "page_parts", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_parts", ["name"], :name => "index_page_parts_on_name"
  add_index "page_parts", ["page_id"], :name => "index_page_parts_on_page_id"

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "location"
    t.text     "title"
    t.text     "description"
    t.text     "keywords"
    t.string   "layout_name"
    t.string   "status"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth",       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["location"], :name => "index_pages_on_location"
  add_index "pages", ["slug"], :name => "index_pages_on_slug"

  create_table "snippets", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "snippets", ["name"], :name => "index_snippets_on_name"

end
