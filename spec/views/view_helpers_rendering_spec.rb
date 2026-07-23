# frozen_string_literal: true

require 'spec_helper'

# Coverage for ActionForm::ViewHelpers#link_to_remove_association (view_helpers.rb:6-22, 42-48).
# The rest of the suite only renders new (non-persisted) parents, so three branches stay dark:
# the *existing* record path (hidden _destroy field), the block form of build_link, and the
# wrapper_class option.
RSpec.describe('ViewHelpersRendering') do

  # The helpers are mixed into ActionView::Base by the engine; pull them into the view-spec
  # context so they can be called alongside the standard form builder.
  include ActionForm::ViewHelpers

  fixtures(:all)

  def form_for(*)
    @output_buffer = super
  end

  it('renders a hidden _destroy field and a remove link for a persisted association') do
    conference_form = ConferenceForm.new(conferences(:ruby))
    speaker = conference_form.speaker

    form_for(conference_form) do |f|
      concat(f.fields_for(:speaker, speaker) do |sf|
        concat(link_to_remove_association('remove speaker', sf))
      end)
    end

    expect(output_buffer).to(include('name="conference[speaker_attributes][_destroy]"'))
    expect(output_buffer).to(include('class="remove_fields existing"'))
    expect(output_buffer).to(include('>remove speaker</a>'))
  end

  it('supports a block and a wrapper_class on the remove link') do
    conference_form = ConferenceForm.new(conferences(:ruby))
    speaker = conference_form.speaker

    form_for(conference_form) do |f|
      concat(f.fields_for(:speaker, speaker) do |sf|
        concat(link_to_remove_association('ignored', sf, wrapper_class: 'nested-wrapper') { 'X' })
      end)
    end

    expect(output_buffer).to(include('data-wrapper-class="nested-wrapper"'))
    expect(output_buffer).to(include('>X</a>'))
  end

end
