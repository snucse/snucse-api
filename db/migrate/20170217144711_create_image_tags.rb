class CreateImageTags < ActiveRecord::Migration[5.0]
  def change
    create_table :image_tags do |t|
      t.integer :attachment_id, null: false
      t.integer :tag_id, null: false
      t.integer :writer_id
      t.float :left
      t.float :top
      t.float :width
      t.float :height

      t.timestamps
    end
  end
end
