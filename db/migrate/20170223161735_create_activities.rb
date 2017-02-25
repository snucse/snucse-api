class CreateActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :activities do |t|
      t.integer :actor_id
      t.integer :profile_id
      t.integer :article_id
      t.references :target, polymorphic: true, index: true
      t.string :action

      t.timestamps
    end
  end
end
