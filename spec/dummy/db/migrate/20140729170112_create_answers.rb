class CreateAnswers < ActiveRecord::Migration[6.0]
  def change
    create_table :answers do |t|
      t.text :content
      t.references :question, index: true

      t.timestamps null: false
    end
  end
end
