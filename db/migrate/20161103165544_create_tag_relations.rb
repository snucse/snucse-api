class CreateTagRelations < ActiveRecord::Migration
  def change
    create_table :tag_relations do |t|
      t.integer :tag_id, null: false
      t.integer :related_tag_id, null: false
      t.integer :writer_id, null: false

      t.timestamps null: false
    end
    add_index :tag_relations, :tag_id
  end
end
