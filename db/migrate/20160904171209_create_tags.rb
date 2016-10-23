class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.integer :creator_id, null: false

      t.timestamps null: false
    end
  end
end
