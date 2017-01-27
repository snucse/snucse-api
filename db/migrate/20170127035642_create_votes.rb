class CreateVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :votes do |t|
      t.integer :survey_id
      t.integer :voter_id
      t.text :content

      t.timestamps null: false
    end
  end
end
