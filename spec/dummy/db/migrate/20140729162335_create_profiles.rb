klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateProfiles < klass
  def change
    create_table :profiles do |t|
      t.string :twitter_name
      t.string :github_name
      t.references :user, index: true

      t.timestamps null: false
    end
  end
end
