# frozen_string_literal: true

class Person < ActiveRecord::Base
  belongs_to :project
end
