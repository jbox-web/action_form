klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateTasks < klass
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
