class CreateConferences < ActiveRecord::Migration[4.2]
  def change
    create_table :conferences do |t|
      t.string :name
      t.string :city

      t.timestamps null: false
    end
  end
end
