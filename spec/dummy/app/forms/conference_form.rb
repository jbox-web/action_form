class ConferenceForm < ActionForm::Base
  attribute :name, required: true
  attribute :city, required: true
  attribute :photo

  association :speaker do
    attribute :name,       required: true
    attribute :occupation, required: true

    association :presentations, records: 2 do
      attribute :topic,    required: true
      attribute :duration, required: true
    end
  end
end
