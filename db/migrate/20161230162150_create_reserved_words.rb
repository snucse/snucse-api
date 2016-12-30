class CreateReservedWords < ActiveRecord::Migration
  def change
    create_table :reserved_words do |t|
      t.string :word

      t.timestamps null: false
    end
    add_index :reserved_words, :word, unique: true
  end
end
