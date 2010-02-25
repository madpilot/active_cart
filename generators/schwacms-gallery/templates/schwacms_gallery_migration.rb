class CreateSchwacmsGallery < ActiveRecord::Migration
  def self.up
    create_table "galleries", :force => true do |t|
      t.integer  "width"
      t.integer  "height"
      t.integer  "thumbnail_width"
      t.integer  "thumbnail_height"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "gallery_images", :force => true do |t|
      t.string   "path"
      t.text     "description"
      t.integer  "gallery_id"
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table "gallery_images"
    drop_table "galleries"
  end
end
