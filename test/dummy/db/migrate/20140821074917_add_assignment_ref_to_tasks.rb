class AddAssignmentRefToTasks < ActiveRecord::Migration[4.2]
  def change
    add_reference :tasks, :assignment, index: true
  end
end
