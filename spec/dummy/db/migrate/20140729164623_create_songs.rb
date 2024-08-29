# frozen_string_literal: true

class CreateSongs < ActiveRecord::Migration[6.0]
  def change
    create_table :songs do |t|
      t.string :title
      t.string :length

      t.timestamps null: false
    end
  end
end
