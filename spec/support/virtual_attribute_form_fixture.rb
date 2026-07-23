# frozen_string_literal: true

# A root-level virtual attribute (base.rb:74-78): a plain accessor on the form that is
# NOT delegated to the model (User has no password_confirmation column).
class VirtualAttributeFormFixture < ActionForm::Base
  self.main_model = :user

  attribute :name
  virtual_attribute :password_confirmation
end
