class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :writer_id
      t.integer :article_id
      t.integer :parent_comment_id
      t.text :content
      t.string :anonymous_name
      t.string :password_digest
      t.string :legacy_password_digest
      t.integer :recommendation_count, default: 0
      t.integer :reply_count, default: 0

      t.timestamps null: false
    end
  end
end
