class CreateSurveys < ActiveRecord::Migration[5.0]
  def change
    create_table :surveys do |t|
      t.integer :creator_id
      t.integer :article_id
      t.string :title
      t.integer :survey_type, default: 0
      t.datetime :start_time
      t.datetime :end_time
      t.text :content

      t.timestamps null: false
    end
  end
end
