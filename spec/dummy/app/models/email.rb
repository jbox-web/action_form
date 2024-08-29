# frozen_string_literal: true

class Email < ActiveRecord::Base
  belongs_to :user

  validates :address, uniqueness: true
end
