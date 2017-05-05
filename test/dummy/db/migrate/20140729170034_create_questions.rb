klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateQuestions < klass
  def change
    create_table :questions do |t|
      t.text :content
      t.references :survey, index: true

      t.timestamps null: false
    end
  end
end
