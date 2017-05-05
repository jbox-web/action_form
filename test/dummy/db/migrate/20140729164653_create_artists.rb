klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateArtists < klass
  def change
    create_table :artists do |t|
      t.string :name
      t.references :song, index: true

      t.timestamps null: false
    end
  end
end
