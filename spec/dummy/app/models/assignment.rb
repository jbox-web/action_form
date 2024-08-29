# frozen_string_literal: true

class Assignment < ActiveRecord::Base
  has_many :tasks
  validates :name, uniqueness: true
end
