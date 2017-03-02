class CreateLegacyObjects < ActiveRecord::Migration[5.0]
  def change
    create_table :legacy_objects do |t|
      t.integer :uid
      t.references :target, polymorphic: true, index: true

      t.timestamps
    end
    add_index :legacy_objects, :uid
  end
end
