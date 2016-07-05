class CreateAssignments < ActiveRecord::Migration[4.2]
  def change
    create_table :assignments do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
