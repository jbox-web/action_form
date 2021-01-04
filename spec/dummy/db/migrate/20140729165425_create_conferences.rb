klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateConferences < klass
  def change
    create_table :conferences do |t|
      t.string :name
      t.string :city

      t.timestamps null: false
    end
  end
end
