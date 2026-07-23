# frozen_string_literal: true

require 'spec_helper'

# Regression specs for the issues surfaced in AUDIT-2026-07-23.md
RSpec.describe('AuditRegression') do

  fixtures(:projects, :tasks, :people, :conferences, :speakers)

  # PERF/CON-form.rb:56 — attributes must be tracked per form instance, not on the
  # shared ActionForm::Form class (unbounded growth + cross-form contamination).
  it('a nested form exposes only its own declared attributes') do
    speaker = ConferenceForm.new(Conference.new).speaker

    # Instantiating an unrelated form must not leak its attributes into ours.
    ProjectForm.new(Project.new)

    expect(speaker.attributes).to(contain_exactly(:name, :occupation))
    expect(speaker.attributes).to_not(include(:tag_id, :topic, :description))
  end

  it('re-instantiating a form does not accumulate attributes across instances') do
    first  = ConferenceForm.new(Conference.new).speaker
    second = ConferenceForm.new(Conference.new).speaker

    expect(first.attributes).to(eq(second.attributes))
    expect(second.attributes.size).to(eq(2))
  end

  # ERR-form_collection.rb:118 — an id that matches no loaded child form must raise a
  # defined error (as accepts_nested_attributes_for does), not NoMethodError on nil.
  it('raises RecordNotFound when a nested id matches no child record') do
    form = ProjectForm.new(projects(:yard))
    params = { tasks_attributes: { '0' => { name: 'Ghost', id: 999_999 } } }

    expect { form.submit(params) }.to(raise_error(ActiveRecord::RecordNotFound))
  end

  # COR-form_collection.rb:86 — an all-blank new nested row on a persisted parent must be
  # rejected, symmetrically with the non-persisted path.
  it('does not create an all-blank new nested record on a persisted parent') do
    project = Project.create!(name: 'Persisted', description: 'd')
    form = ProjectForm.new(project)

    form.submit(contributors_attributes: { '0' => { name: '', role: '', description: '' } })

    expect { form.save }.to_not(change(Person, :count))
  end

  # ERR-form_helpers.rb:48 — a nested-attributes key with no matching declared association
  # must raise a clear error, not a NoMethodError on nil.
  it('raises a clear error for attributes of an undeclared association') do
    form = ProjectForm.new(Project.new)

    expect { form.submit(bogus_attributes: { name: 'x' }) }
      .to(raise_error(ArgumentError, /No association bogus/))
  end

  # API-form.rb:126 — respond_to? must be consistent with the methods method_missing intercepts.
  it('responds to the DSL methods it intercepts through method_missing') do
    speaker = ConferenceForm.new(Conference.new).speaker

    expect(speaker.respond_to?(:validates)).to(be(true))
    expect(speaker.respond_to?(:validate)).to(be(true))
    expect(speaker.respond_to?(:id=)).to(be(true))
    expect(speaker.respond_to?(:some_undefined_method)).to(be(false))
  end

  it('responds to registered external validation methods') do
    ActionForm.external_validation_methods << :validates_phone_number
    speaker = ConferenceForm.new(Conference.new).speaker

    expect(speaker.respond_to?(:validates_phone_number)).to(be(true))
  ensure
    ActionForm.external_validation_methods.delete(:validates_phone_number)
  end

  # COR-form_collection.rb:169 — for a non-persisted parent, #submit calls enforce_records_limit,
  # which must handle ActionController::Parameters (Rails 8.1 has no #size on it), not just Hash.
  it('submits a new-parent nested collection through real strong params (Parameters)') do
    form = ProjectForm.new(Project.new)
    raw = { 'name'             => 'Fresh',
            'tasks_attributes' => { '0' => { 'name' => 'Dig' } }, }
    params = ActionController::Parameters.new(raw).permit(:name, tasks_attributes: %i[name])

    expect { form.submit(params) }.to_not(raise_error)
    expect(form.tasks.map(&:name)).to(include('Dig'))
  end

  # TEST-form_collection.rb:21 — the real controller path passes ActionController::Parameters
  # (string keys). Guards that update-by-id routes to update, not create, via indifferent access.
  it('updates an existing nested record through real strong params (string keys)') do
    project = projects(:yard)
    form = ProjectForm.new(project)
    raw = { 'name'             => 'Life',
            'tasks_attributes' => { '0' => { 'name' => 'Eat', 'id' => tasks(:rake).id.to_s } }, }
    params = ActionController::Parameters.new(raw).permit(:name, tasks_attributes: %i[name id])

    form.submit(params)

    expect { form.save }.to_not(change(Task, :count))
    expect(form.tasks.map(&:name)).to(include('Eat'))
  end

end
