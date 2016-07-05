class AddOwnerToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :owner_id, :integer
  end
end
