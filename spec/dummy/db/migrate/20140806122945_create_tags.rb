klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateTags < klass
  def change
    create_table :tags do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
