# frozen_string_literal: true

# A has_many collection declared with records: 0 (no pre-rendered blank rows). Nested rows
# arrive dynamically, keyed sequentially by a programmatic caller that builds params itself
# rather than through link_to_add_association's timestamp keys.
class ZeroRecordsFormFixture < ActionForm::Base
  self.main_model = :project

  attribute :name

  association :tasks, records: 0 do
    attribute :name
    attribute :description
    attribute :done
  end
end
