# frozen_string_literal: true

class AddAssignmentRefToTasks < ActiveRecord::Migration[6.0]
  def change
    add_reference :tasks, :assignment, index: true
  end
end
