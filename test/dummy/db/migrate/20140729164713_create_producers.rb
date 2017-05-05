klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateProducers < klass
  def change
    create_table :producers do |t|
      t.string :name
      t.string :studio
      t.references :artist, index: true

      t.timestamps null: false
    end
  end
end
