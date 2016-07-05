class CreateSongs < ActiveRecord::Migration[4.2]
  def change
    create_table :songs do |t|
      t.string :title
      t.string :length

      t.timestamps null: false
    end
  end
end
