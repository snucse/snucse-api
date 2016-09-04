class CreateProfilesTags < ActiveRecord::Migration
  def change
    create_table :profiles_tags do |t|
      t.integer :profile_id, null: false
      t.integer :tag_id, null: false
    end
  end
end
