# frozen_string_literal: true

class CreateAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :assignments do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
