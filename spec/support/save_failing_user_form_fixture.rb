# frozen_string_literal: true

# Root form over SaveFailingUser, used to exercise the rollback branch when the root model
# fails to persist (base.rb:107).
class SaveFailingUserFormFixture < ActionForm::Base
  self.main_model = :user
  self.main_class = SaveFailingUser

  attribute :name
  attribute :age
  attribute :gender
end
