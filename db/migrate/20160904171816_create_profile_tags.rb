class CreateProfileTags < ActiveRecord::Migration
  def change
    create_table :profile_tags do |t|
      t.integer :profile_id, null: false
      t.integer :tag_id, null: false

      t.timestamps null: false
    end
  end
end
