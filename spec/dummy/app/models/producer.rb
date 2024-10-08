# frozen_string_literal: true

class Producer < ActiveRecord::Base
  belongs_to :artist

  validates :name, :studio, uniqueness: true
end
