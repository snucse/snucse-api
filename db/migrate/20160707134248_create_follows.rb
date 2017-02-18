class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.integer :user_id
      t.integer :profile_id
      t.boolean :star, default: false
      t.integer :tab

      t.timestamps null: false
    end
  end
end
