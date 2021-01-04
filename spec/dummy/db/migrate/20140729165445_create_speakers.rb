klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateSpeakers < klass
  def change
    create_table :speakers do |t|
      t.string :name
      t.string :occupation
      t.references :conference, index: true

      t.timestamps null: false
    end
  end
end
