class CreateRecommendationCounts < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendation_counts do |t|
      t.integer :article_id, null: false
      t.date :date, null: false
      t.integer :count, default: 0

      t.timestamps
    end
  end
end
