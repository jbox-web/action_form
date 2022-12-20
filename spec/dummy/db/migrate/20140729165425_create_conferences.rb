class CreateConferences < ActiveRecord::Migration[6.0]
  def change
    create_table :conferences do |t|
      t.string :name
      t.string :city

      t.timestamps null: false
    end
  end
end
