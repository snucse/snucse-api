class CreateProfileComments < ActiveRecord::Migration
  def change
    create_table :profile_comments do |t|
      t.integer :writer_id
      t.integer :profile_id
      t.integer :parent_comment_id
      t.text :content
      t.integer :recommendation_count, default: 0
      t.integer :reply_count, default: 0

      t.timestamps null: false
    end
  end
end
