klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateEmails < klass
  def change
    create_table :emails do |t|
      t.string :address
      t.references :user, index: true

      t.timestamps null: false
    end
  end
end
