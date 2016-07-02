class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :writer_id
      t.integer :article_id
      t.text :content

      t.timestamps null: false
    end
  end
end
