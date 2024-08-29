# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :name
      t.string :description
      t.boolean :done
      t.references :project, index: true

      t.timestamps null: false
    end
  end
end
