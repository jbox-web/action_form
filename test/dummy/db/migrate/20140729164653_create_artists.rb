class CreateArtists < ActiveRecord::Migration[4.2]
  def change
    create_table :artists do |t|
      t.string :name
      t.references :song, index: true

      t.timestamps null: false
    end
  end
end
