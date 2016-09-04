class CreateFavoriteArticles < ActiveRecord::Migration
  def change
    create_table :favorite_articles do |t|
      t.integer :user_id
      t.integer :article_id

      t.timestamps null: false
    end
  end
end
