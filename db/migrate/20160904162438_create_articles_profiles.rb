class CreateArticlesProfiles < ActiveRecord::Migration
  def change
    create_table :articles_profiles do |t|
      t.integer :article_id, null: false
      t.integer :profile_id, null: false
    end
  end
end
