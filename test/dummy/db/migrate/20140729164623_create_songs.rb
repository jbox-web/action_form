klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateSongs < klass
  def change
    create_table :songs do |t|
      t.string :title
      t.string :length

      t.timestamps null: false
    end
  end
end
