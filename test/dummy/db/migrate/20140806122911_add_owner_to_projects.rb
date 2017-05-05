klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class AddOwnerToProjects < klass
  def change
    add_column :projects, :owner_id, :integer
  end
end
