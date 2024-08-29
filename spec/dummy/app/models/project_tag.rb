# frozen_string_literal: true

class ProjectTag < ActiveRecord::Base
  belongs_to :project
  belongs_to :tag
end
