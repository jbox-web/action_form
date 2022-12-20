class CreateProjectTags < ActiveRecord::Migration[6.0]
  def change
    create_table :project_tags do |t|
      t.references :project, index: true
      t.references :tag, index: true

      t.timestamps null: false
    end
  end
end
