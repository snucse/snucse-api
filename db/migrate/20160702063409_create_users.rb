class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.string :name
      t.string :profile_image
      t.string :legacy_password_digest
      t.integer :level, default: 0

      t.timestamps null: false
    end
  end
end
