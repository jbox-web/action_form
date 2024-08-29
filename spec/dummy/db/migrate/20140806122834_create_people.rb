# frozen_string_literal: true

class CreatePeople < ActiveRecord::Migration[6.0]
  def change
    create_table :people do |t|
      t.string :name
      t.string :role
      t.string :description
      t.references :project, index: true

      t.timestamps null: false
    end
  end
end
