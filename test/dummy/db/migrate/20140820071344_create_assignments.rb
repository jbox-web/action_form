klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateAssignments < klass
  def change
    create_table :assignments do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
