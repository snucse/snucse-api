class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer :article_id
      t.integer :uploader_id
      t.string :file
      t.string :password_digest
      t.string :legacy_password_digest

      t.timestamps null: false
    end
  end
end
