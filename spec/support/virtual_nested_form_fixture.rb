# frozen_string_literal: true

# A virtual attribute declared inside an association block (form.rb:82-87): evaluated at
# the nested Form instance level.
class VirtualNestedFormFixture < ActionForm::Base
  self.main_model = :project

  association :owner do
    attribute :name
    virtual_attribute :captcha
  end
end
