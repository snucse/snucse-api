class CreateProfileComments < ActiveRecord::Migration
  def change
    create_table :profile_comments do |t|
      t.integer :writer_id
      t.integer :profile_id
      t.text :content

      t.timestamps null: false
    end
  end
end
