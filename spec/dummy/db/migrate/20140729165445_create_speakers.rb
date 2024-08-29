# frozen_string_literal: true

class CreateSpeakers < ActiveRecord::Migration[6.0]
  def change
    create_table :speakers do |t|
      t.string :name
      t.string :occupation
      t.references :conference, index: true

      t.timestamps null: false
    end
  end
end
