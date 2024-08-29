# frozen_string_literal: true

class SubTask < ActiveRecord::Base
  belongs_to :task
end
