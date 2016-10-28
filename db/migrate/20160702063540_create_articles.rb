class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.integer :writer_id
      t.string :title
      t.text :content
      t.string :anonymous_name
      t.string :password_digest
      t.string :legacy_password_digest

      t.timestamps null: false
    end
  end
end
