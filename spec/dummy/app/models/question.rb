# frozen_string_literal: true

class Question < ActiveRecord::Base
  belongs_to :survey
  has_many :answers, dependent: :destroy
end
