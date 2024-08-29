# frozen_string_literal: true

class Poro
  include ActiveModel::Model

  attr_accessor :name, :city

  def save
    true
  end
end

class PoroFormFixture < ActionForm::Base
  self.main_model = :conference
  attribute :name, required: true
  attribute :city, required: true
end
