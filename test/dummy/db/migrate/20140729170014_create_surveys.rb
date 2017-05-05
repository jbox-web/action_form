klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateSurveys < klass
  def change
    create_table :surveys do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
