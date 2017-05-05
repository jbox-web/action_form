klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreatePeople < klass
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
