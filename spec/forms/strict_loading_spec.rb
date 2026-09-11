# frozen_string_literal: true

require 'spec_helper'

# Coverage for form_collection.rb *associated_records*: the collection is re-read
# from the parent association both when the form is built and in the *after_save*
# that syncs child forms back. On a parent flagged by
# *config.active_record.strict_loading_by_default*, that read raises
# ActiveRecord::StrictLoadingViolationError — on a query that is single and
# legitimate, and that the caller cannot preload away, since the parent is already
# persisted by the time the re-read happens.
RSpec.describe('StrictLoading') do

  fixtures(:projects, :tasks, :people)

  it('rebuilds a collection on a strict-loading parent without raising') do
    project = Project.find(projects(:yard).id)
    project.strict_loading!

    form = ProjectForm.new(project)

    expect { form.submit(name: 'Yard Work Revisited') }.to_not(raise_error)
    expect { form.save }.to_not(raise_error)
  end


  it('keeps reading the collection from the cache when it is already loaded') do
    project = Project.includes(:tasks).find(projects(:yard).id)
    project.strict_loading!

    form = ProjectForm.new(project)
    form.submit(name: 'Yard Work Preloaded')

    expect(form.save).to(be(true))
    expect(project.reload.name).to(eq('Yard Work Preloaded'))
  end

end
