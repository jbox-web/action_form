# frozen_string_literal: true

class UserForm < ActionForm::Base
  self.main_model = :user

  attribute :name,   required: true
  attribute :age,    required: true
  attribute :gender, required: true

  association :email do
    attribute :address, required: true
  end

  association :profile do
    attribute :twitter_name, required: true
    attribute :github_name,  required: true
  end

  validates :name, length: { in: 6..20 }
  validates :age, numericality: { only_integer: true }
end
