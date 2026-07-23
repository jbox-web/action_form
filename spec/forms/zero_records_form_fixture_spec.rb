# frozen_string_literal: true

require 'spec_helper'

# Regression: a collection declared records: 0 (no pre-rendered blank rows) must accept a
# nested row submitted with a plain sequential key by a programmatic caller on a not-yet-
# persisted parent, and create it. A non-cocoon consumer builds its params directly, so its
# dynamic additions carry sequential keys ('0', '1', ...) rather than timestamp keys.
RSpec.describe(ZeroRecordsFormFixture) do
  it('creates a dynamically submitted row for a records: 0 collection without raising') do
    form = described_class.new(Project.new)
    params = { name: 'Fresh', tasks_attributes: { '0' => { name: 'Dig' } } }

    expect { form.submit(params) }.to_not(raise_error)
    expect(form.tasks.map(&:name)).to(include('Dig'))
  end
end
