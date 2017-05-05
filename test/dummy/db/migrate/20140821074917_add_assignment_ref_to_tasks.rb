klass = Rails::VERSION::MAJOR == 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
class AddAssignmentRefToTasks < klass
  def change
    add_reference :tasks, :assignment, index: true
  end
end
