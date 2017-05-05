klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateProjects < klass
  def change
    create_table :projects do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end
  end
end
