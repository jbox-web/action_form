klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateAnswers < klass
  def change
    create_table :answers do |t|
      t.text :content
      t.references :question, index: true

      t.timestamps null: false
    end
  end
end
