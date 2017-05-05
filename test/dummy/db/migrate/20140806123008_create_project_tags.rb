klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class CreateProjectTags < klass
  def change
    create_table :project_tags do |t|
      t.references :project, index: true
      t.references :tag, index: true

      t.timestamps null: false
    end
  end
end
