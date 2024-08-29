# frozen_string_literal: true

class SongForm < ActionForm::Base
  attribute :title,  required: true
  attribute :length, required: true

  association :artist do
    attribute :name, required: true

    association :producer do
      attribute :name,   required: true
      attribute :studio, required: true
    end
  end
end
