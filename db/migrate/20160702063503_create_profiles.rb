class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :sid
      t.string :name
      t.integer :admin_id
      t.text :description

      t.timestamps null: false
    end
    add_index :profiles, :sid, unique: true
  end
end
