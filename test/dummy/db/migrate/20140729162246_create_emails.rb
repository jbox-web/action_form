class CreateEmails < ActiveRecord::Migration[4.2]
  def change
    create_table :emails do |t|
      t.string :address
      t.references :user, index: true

      t.timestamps null: false
    end
  end
end
