# frozen_string_literal: true

class AddOwnerToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :owner_id, :integer
  end
end
