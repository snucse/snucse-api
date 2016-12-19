class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :sid
      t.string :name
      t.integer :admin_id
      t.text :description
      t.boolean :is_public, default: false
      t.integer :comment_count, default: 0

      t.timestamps null: false
    end
    add_index :profiles, :sid, unique: true
  end
end
