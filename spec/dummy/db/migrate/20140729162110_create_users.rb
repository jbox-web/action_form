# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :age
      t.integer :gender

      t.timestamps null: false
    end
  end
end
