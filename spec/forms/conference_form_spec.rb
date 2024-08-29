# frozen_string_literal: true

require 'spec_helper'

RSpec.describe('ConferenceForm') do

  fixtures(:conferences, :speakers, :presentations)

  before do
    @conference = Conference.new
    @form = ConferenceForm.new(@conference)
    @model = @form
  end

  it('contains getter for presentations sub-form') do
    assert_respond_to(@form.speaker, :presentations)
    presentations_form = @form.speaker.forms.first
    expect(presentations_form).to(be_instance_of(ActionForm::FormCollection))
  end

  it("#represents? returns true if the argument matches the Form's association name, false otherwise") do
    presentations_form = @form.speaker.forms.first
    expect(presentations_form.represents?('presentations')).to(be(true))
    expect(presentations_form.represents?('presentation')).to(be(false))
  end

  it('main form provides getter method for collection objects') do
    assert_respond_to(@form.speaker, :presentations)
    presentations = @form.speaker.presentations
    presentations.each do |form|
      expect(form).to(be_instance_of(ActionForm::Form))
      expect(form.model).to(be_instance_of(Presentation))
    end
  end

  it('presentations sub-form contains association name and parent model') do
    presentations_form = @form.speaker.forms.first
    expect(presentations_form.association_name).to(eq(:presentations))
    expect(presentations_form.records).to(eq(2))
    expect(presentations_form.parent).to(eq(@form.speaker.model))
  end

  it('presentations sub-form initializes the number of records specified') do
    presentations_form = @form.speaker.forms.first
    assert_respond_to(presentations_form, :models)
    expect(presentations_form.models.size).to(eq(2))
    presentations_form.each do |form|
      expect(form).to(be_instance_of(ActionForm::Form))
      expect(form.model).to(be_instance_of(Presentation))
      assert_respond_to(form, :topic)
      assert_respond_to(form, :topic=)
      assert_respond_to(form, :duration)
      assert_respond_to(form, :duration=)
    end
    expect(@form.speaker.model.presentations.size).to(eq(2))
  end

  it('presentations sub-form fetches parent and association objects') do
    conference = conferences(:ruby)
    form = ConferenceForm.new(conference)
    expect(form.name).to(eq(conference.name))
    expect(form.speaker.presentations.size).to(eq(2))
    expect(form.speaker.presentations[0].model).to(eq(conference.speaker.presentations[0]))
    expect(form.speaker.presentations[1].model).to(eq(conference.speaker.presentations[1]))
  end

  it('main form syncs its model and the models in nested sub-forms') do
    @form.submit(default_params)
    expect(@form.name).to(eq('Euruco'))
    expect(@form.city).to(eq('Athens'))
    expect(@form.speaker.name).to(eq('Peter Markou'))
    expect(@form.speaker.occupation).to(eq('Developer'))
    expect(@form.speaker.presentations[0].topic).to(eq('Ruby OOP'))
    expect(@form.speaker.presentations[0].duration).to(eq('1h'))
    expect(@form.speaker.presentations[1].topic).to(eq('Ruby Closures'))
    expect(@form.speaker.presentations[1].duration).to(eq('1h'))
    expect(@form.speaker.presentations.size).to(eq(2))
  end

  it('main form validates itself') do
    @form.submit(merge_params(speaker_attributes: { name: 'Unique Name' }))
    expect(@form.valid?).to(be(true))
  end

  it('validation with empty params') do
    @form.submit({})
    expect(@form.valid?).to(be(false))
    expect(@form.errors[:name]).to include("can't be blank")
    expect(@form.errors[:name].size).to(eq(1))
    expect(@form.errors[:city]).to include("can't be blank")
    expect(@form.errors[:city].size).to(eq(1))
    expect(@form.errors['speaker.name']).to include("can't be blank")
    expect(@form.errors['speaker.occupation']).to include("can't be blank")
    expect(@form.errors['speaker.presentations.topic']).to include("can't be blank")
    expect(@form.errors['speaker.presentations.topic'].size).to(eq(2))
    expect(@form.errors['speaker.presentations.duration']).to include("can't be blank")
    expect(@form.errors['speaker.presentations.duration'].size).to(eq(2))
  end

  it('main form validates the models') do
    @form.submit(speaker_attributes: { name: conferences(:ruby).speaker.name })
    expect(@form.valid?).to(be(false))
    expect(@form.errors['name']).to include("can't be blank")
    expect(@form.errors['speaker.name']).to include('has already been taken')
  end

  it('presentations sub-form raises error if records exceed the allowed number') do
    skip('TODO')
    params = { name: 'Euruco', city: 'Athens', speaker_attributes: { name: 'Petros Markou', occupation: 'Developer', presentations_attributes: { '0' => { topic: 'Ruby OOP', duration: '1h' }, '1' => { topic: 'Ruby Closures', duration: '1h' }, '2' => { topic: 'Ruby Blocks', duration: '1h' } } } }
    exception = expect { @form.submit(params) }.to(raise_error(ActionForm::TooManyRecords))
    expect(exception.message).to(eq('Maximum 2 records are allowed. Got 3 records instead.'))
  end

  it('main form saves its model and the models in nested sub-forms') do
    @form.submit(merge_params(speaker_attributes: { name: 'Petros Markou' }))
    expect { @form.save }.to change(Conference, :count).by(1).and change(Speaker, :count).by(1)
    expect(@form.name).to(eq('Euruco'))
    expect(@form.city).to(eq('Athens'))
    expect(@form.speaker.name).to(eq('Petros Markou'))
    expect(@form.speaker.occupation).to(eq('Developer'))
    expect(@form.speaker.presentations[0].topic).to(eq('Ruby OOP'))
    expect(@form.speaker.presentations[0].duration).to(eq('1h'))
    expect(@form.speaker.presentations[1].topic).to(eq('Ruby Closures'))
    expect(@form.speaker.presentations[1].duration).to(eq('1h'))
    expect(@form.speaker.presentations.size).to(eq(2))
    expect(@form.persisted?).to(be(true))
    expect(@form.speaker.persisted?).to(be(true))
    @form.speaker.presentations.each do |presentation|
      expect(presentation.persisted?).to(be(true))
    end
  end

  it('main form saves its model and dynamically added models in nested sub-forms') do
    @form.submit(merge_params(speaker_attributes: { name: 'Petros Markou', presentations_attributes: { '1404292088779' => { topic: 'Ruby Blocks', duration: '1h' } } }))
    expect { @form.save }.to change(Conference, :count).by(1).and change(Speaker, :count).by(1)
    expect(@form.name).to(eq('Euruco'))
    expect(@form.city).to(eq('Athens'))
    expect(@form.speaker.name).to(eq('Petros Markou'))
    expect(@form.speaker.occupation).to(eq('Developer'))
    expect(@form.speaker.presentations[0].topic).to(eq('Ruby OOP'))
    expect(@form.speaker.presentations[0].duration).to(eq('1h'))
    expect(@form.speaker.presentations[1].topic).to(eq('Ruby Closures'))
    expect(@form.speaker.presentations[1].duration).to(eq('1h'))
    expect(@form.speaker.presentations[2].topic).to(eq('Ruby Blocks'))
    expect(@form.speaker.presentations[2].duration).to(eq('1h'))
    expect(@form.speaker.presentations.size).to(eq(3))
    expect(@form.persisted?).to(be(true))
    expect(@form.speaker.persisted?).to(be(true))
    @form.speaker.presentations.each do |presentation|
      expect(presentation.persisted?).to(be(true))
    end
  end

  it('main form updates its model and the models in nested sub-forms') do
    conference = conferences(:ruby)
    form = ConferenceForm.new(conference)
    form.submit(merge_params(speaker_attributes: { presentations_attributes: { '0' => { topic: 'Rails OOP', duration: '1h', id: presentations(:ruby_oop).id }, '1' => { topic: 'Rails Patterns', duration: '1h', id: presentations(:ruby_closures).id } } }))
    expect { form.save }.to change(Conference, :count).by(0).and change(Speaker, :count).by(0).and change(Presentation, :count).by(0)
    expect(form.name).to(eq('Euruco'))
    expect(form.city).to(eq('Athens'))
    expect(form.speaker.name).to(eq('Peter Markou'))
    expect(form.speaker.occupation).to(eq('Developer'))
    expect(form.speaker.presentations[0].topic).to(eq('Rails Patterns'))
    expect(form.speaker.presentations[0].duration).to(eq('1h'))
    expect(form.speaker.presentations[1].topic).to(eq('Rails OOP'))
    expect(form.speaker.presentations[1].duration).to(eq('1h'))
    expect(form.speaker.presentations.size).to(eq(2))
    expect(form.persisted?).to(be(true))
  end

  it('main form updates its model and saves dynamically added models in nested sub-forms') do
    conference = conferences(:ruby)
    form = ConferenceForm.new(conference)
    form.submit(merge_params(speaker_attributes: { presentations_attributes: { '0' => { topic: 'Rails OOP', duration: '1h', id: presentations(:ruby_oop).id }, '1' => { topic: 'Rails Patterns', duration: '1h', id: presentations(:ruby_closures).id }, '1404292088779' => { topic: 'Rails Migrations', duration: '1h' } } }))
    expect { form.save }.to change(Conference, :count).by(0).and change(Speaker, :count).by(0)
    expect(form.name).to(eq('Euruco'))
    expect(form.city).to(eq('Athens'))
    expect(form.speaker.name).to(eq('Peter Markou'))
    expect(form.speaker.occupation).to(eq('Developer'))
    expect(form.speaker.presentations[0].topic).to(eq('Rails Patterns'))
    expect(form.speaker.presentations[0].duration).to(eq('1h'))
    expect(form.speaker.presentations[1].topic).to(eq('Rails OOP'))
    expect(form.speaker.presentations[1].duration).to(eq('1h'))
    expect(form.speaker.presentations[2].topic).to(eq('Rails Migrations'))
    expect(form.speaker.presentations[2].duration).to(eq('1h'))
    expect(form.speaker.presentations.size).to(eq(3))
    expect(form.persisted?).to(be(true))
  end

  it('main form deletes models in nested sub-forms') do
    conference = conferences(:ruby)
    form = ConferenceForm.new(conference)
    form.submit(merge_params(speaker_attributes: { presentations_attributes: { '0' => { :topic => 'Rails OOP', :duration => '1h', :id => presentations(:ruby_oop).id, '_destroy' => '1' }, '1' => { topic: 'Rails Patterns', duration: '1h', id: presentations(:ruby_closures).id } } }))
    expect(conference.speaker.presentations[1].marked_for_destruction?).to(be(true))
    expect { form.save }.to change(Conference, :count).by(0).and change(Speaker, :count).by(0)
    expect(form.name).to(eq('Euruco'))
    expect(form.city).to(eq('Athens'))
    expect(form.speaker.name).to(eq('Peter Markou'))
    expect(form.speaker.occupation).to(eq('Developer'))
    expect(form.speaker.presentations[0].topic).to(eq('Rails Patterns'))
    expect(form.speaker.presentations[0].duration).to(eq('1h'))
    expect(form.speaker.presentations.size).to(eq(1))
    expect(form.persisted?).to(be(true))
    form.speaker.presentations.each do |presentation|
      expect(presentation.persisted?).to(be(true))
    end
  end

  it('main form deletes and adds models in nested sub-forms') do
    conference = conferences(:ruby)
    form = ConferenceForm.new(conference)
    form.submit(merge_params(speaker_attributes: { presentations_attributes: { '0' => { :topic => 'Rails OOP', :duration => '1h', :id => presentations(:ruby_oop).id, '_destroy' => '1' }, '1' => { topic: 'Rails Patterns', duration: '1h', id: presentations(:ruby_closures).id }, '1404292088779' => { topic: 'Rails Testing', duration: '2h' } } }))
    expect { form.save }.to change(Conference, :count).by(0).and change(Speaker, :count).by(0)
    expect(form.name).to(eq('Euruco'))
    expect(form.city).to(eq('Athens'))
    expect(form.speaker.name).to(eq('Peter Markou'))
    expect(form.speaker.occupation).to(eq('Developer'))
    expect(form.speaker.presentations[0].topic).to(eq('Rails Patterns'))
    expect(form.speaker.presentations[0].duration).to(eq('1h'))
    expect(form.speaker.presentations[1].topic).to(eq('Rails Testing'))
    expect(form.speaker.presentations[1].duration).to(eq('2h'))
    expect(form.speaker.presentations.size).to(eq(2))
    expect(form.persisted?).to(be(true))
    form.speaker.presentations.each do |presentation|
      expect(presentation.persisted?).to(be(true))
    end
  end

  it('main form responds to writer method') do
    assert_respond_to(@form, :speaker_attributes=)
  end

  it('speaker sub-form responds to writer method') do
    assert_respond_to(@form.speaker, :presentations_attributes=)
  end

  # TODO: fixme
  # it("accepts file") do
  #   @form.submit(merge_params(:photo => fixture_file_upload("demo.txt", "text/plain"), :speaker_attributes => ({ :name => "Unique Name" })))
  #   expect(@form.valid?).to(eq(true))
  #   expect("demo.txt").to(eq(@form.photo))
  # end

  private

    def merge_params(params)
      default_params.deep_merge(params)
    end

    def default_params
      @default_params ||= { name: 'Euruco', city: 'Athens', speaker_attributes: { name: 'Peter Markou', occupation: 'Developer', presentations_attributes: { '0' => { topic: 'Ruby OOP', duration: '1h' }, '1' => { topic: 'Ruby Closures', duration: '1h' } } } }
    end

end
