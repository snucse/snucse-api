class CreateArticleTags < ActiveRecord::Migration
  def change
    create_table :article_tags do |t|
      t.integer :article_id, null: false
      t.integer :tag_id, null: false
      t.integer :writer_id, null: false

      t.timestamps null: false
    end
  end
end
