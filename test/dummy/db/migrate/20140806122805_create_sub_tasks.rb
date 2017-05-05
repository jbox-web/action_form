klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateSubTasks < klass
  def change
    create_table :sub_tasks do |t|
      t.string :name
      t.string :description
      t.boolean :done
      t.references :task, index: true

      t.timestamps null: false
    end
  end
end
