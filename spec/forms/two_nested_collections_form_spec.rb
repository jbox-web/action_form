# frozen_string_literal: true

require 'spec_helper'

RSpec.describe('TwoNestedCollectionsForm') do

  fixtures(:surveys, :questions, :answers)

  before do
    @survey = Survey.new
    @form = SurveyForm.new(@survey)
    @model = @form
  end

  it('main form provides getter method for questions collection form') do
    questions_form = @form.forms.first
    expect(questions_form).to(be_instance_of(ActionForm::FormCollection))
  end

  it("#represents? returns true if the argument matches the Form's association name, false otherwise") do
    questions_form = @form.forms.first
    expect(questions_form.represents?('questions')).to(be(true))
    expect(questions_form.represents?('question')).to(be(false))
  end

  it('main form provides getter method for collection objects') do
    assert_respond_to(@form, :questions)
    questions = @form.questions
    questions.each do |form|
      expect(form).to(be_instance_of(ActionForm::Form))
      expect(form.model).to(be_instance_of(Question))
    end
  end

  it('questions sub-form contains association name and parent model') do
    questions_form = @form.forms.first
    expect(questions_form.association_name).to(eq(:questions))
    expect(questions_form.records).to(eq(1))
    expect(questions_form.parent).to(eq(@survey))
  end

  it('each questions_form declares a answers FormCollection') do
    questions_form = @form.forms.first
    expect(questions_form.forms.size).to(eq(1))
    @form.questions.each do |question_form|
      expect(question_form).to(be_instance_of(ActionForm::Form))
      expect(question_form.model).to(be_instance_of(Question))
      expect(questions_form.forms.size).to(eq(1))
      answers = question_form.answers
      answers.each do |answer_form|
        expect(answer_form).to(be_instance_of(ActionForm::Form))
        expect(answer_form.model).to(be_instance_of(Answer))
      end
    end
  end

  it('main form initializes the number of records specified') do
    questions_form = @form.forms.first
    assert_respond_to(questions_form, :models)
    expect(questions_form.models.size).to(eq(1))
    questions_form.each do |form|
      expect(form).to(be_instance_of(ActionForm::Form))
      expect(form.model).to(be_instance_of(Question))
      assert_respond_to(form, :content)
      assert_respond_to(form, :content=)
      answers_form = form.forms.first
      assert_respond_to(answers_form, :models)
      expect(answers_form.models.size).to(eq(2))
      answers_form.each do |answer_form|
        expect(answer_form).to(be_instance_of(ActionForm::Form))
        expect(answer_form.model).to(be_instance_of(Answer))
        assert_respond_to(answer_form, :content)
        assert_respond_to(answer_form, :content=)
      end
    end
    expect(@form.model.questions.size).to(eq(1))
  end

  it('main form fetches parent and association objects') do
    survey = surveys(:programming)
    form = SurveyForm.new(survey)
    expect(form.name).to(eq(survey.name))
    expect(form.questions.size).to(eq(1))
    expect(form.questions[0].model).to(eq(survey.questions[0]))
    expect(form.questions[0].answers[0].model).to(eq(survey.questions[0].answers[0]))
    expect(form.questions[0].answers[1].model).to(eq(survey.questions[0].answers[1]))
  end

  it('main form syncs its model and the models in nested sub-forms') do
    params = { name: 'Programming languages', questions_attributes: { '0' => { content: 'Which language allows closures?', answers_attributes: { '0' => { content: 'Ruby Programming Language' }, '1' => { content: 'CSharp Programming Language' } } } } }
    @form.submit(params)
    expect(@form.name).to(eq('Programming languages'))
    expect(@form.questions[0].content).to(eq('Which language allows closures?'))
    expect(@form.questions[0].answers[0].content).to(eq('Ruby Programming Language'))
    expect(@form.questions[0].answers[1].content).to(eq('CSharp Programming Language'))
    expect(@form.questions.size).to(eq(1))
  end

  it('main form validates itself') do
    params = { name: 'Programming languages', questions_attributes: { '0' => { content: 'Which language allows closures?', answers_attributes: { '0' => { content: 'Ruby Programming Language' }, '1' => { content: 'CSharp Programming Language' } } } } }
    @form.submit(params)
    expect(@form.valid?).to(be(true))
    params = { name: nil, questions_attributes: { '0' => { content: nil, answers_attributes: { '0' => { content: nil }, '1' => { content: nil } } } } }
    @form.submit(params)
    expect(@form.valid?).to(be(false))
    expect(@form.errors[:name]).to include("can't be blank")
    expect(@form.errors['questions.content']).to include("can't be blank")
    expect(@form.errors['questions.answers.content']).to include("can't be blank")
  end

  it('main form validates the model') do
    params = { name: surveys(:programming).name, questions_attributes: { '0' => { content: 'Which language allows closures?', answers_attributes: { '0' => { content: 'Ruby Programming Language' }, '1' => { content: 'CSharp Programming Language' } } } } }
    @form.submit(params)
    expect(@form.valid?).to(be(false))
    expect(@form.errors.messages[:name]).to include('has already been taken')
  end

  it('main form saves its model and the models in nested sub-forms') do
    params = { name: 'Programming languages', questions_attributes: { '0' => { content: 'Which language allows closures?', answers_attributes: { '0' => { content: 'Ruby Programming Language' }, '1' => { content: 'CSharp Programming Language' } } } } }
    @form.submit(params)
    expect { @form.save }.to(change(Survey, :count))
    expect(@form.name).to(eq('Programming languages'))
    expect(@form.questions[0].content).to(eq('Which language allows closures?'))
    expect(@form.questions[0].answers[0].content).to(eq('Ruby Programming Language'))
    expect(@form.questions[0].answers[1].content).to(eq('CSharp Programming Language'))
    expect(@form.questions.size).to(eq(1))
    expect(@form.persisted?).to(be(true))
    @form.questions.each do |question|
      expect(question.persisted?).to(be(true))
      expect(question.answers.size).to(eq(2))
      question.answers.each { |answer| expect(answer.persisted?).to(be(true)) }
    end
  end

  it('main form saves its model and dynamically added models in nested sub-forms') do
    params = { name: 'Programming languages', questions_attributes: { '0' => { content: 'Which language allows closures?', answers_attributes: { '0' => { content: 'Ruby Programming Language' }, '1' => { content: 'CSharp Programming Language' } } }, '1404292088779' => { content: 'Which language allows blocks?', answers_attributes: { '0' => { content: 'Ruby Programming Language' }, '1' => { content: 'C Programming Language' } } } } }
    @form.submit(params)
    expect { @form.save }.to(change(Survey, :count))
    expect(@form.name).to(eq('Programming languages'))
    expect(@form.questions[0].content).to(eq('Which language allows closures?'))
    expect(@form.questions[0].answers[0].content).to(eq('Ruby Programming Language'))
    expect(@form.questions[0].answers[1].content).to(eq('CSharp Programming Language'))
    expect(@form.questions[1].content).to(eq('Which language allows blocks?'))
    expect(@form.questions[1].answers[0].content).to(eq('Ruby Programming Language'))
    expect(@form.questions[1].answers[1].content).to(eq('C Programming Language'))
    expect(@form.questions.size).to(eq(2))
    expect(@form.persisted?).to(be(true))
    @form.questions.each do |question|
      expect(question.persisted?).to(be(true))
      expect(question.answers.size).to(eq(2))
      question.answers.each { |answer| expect(answer.persisted?).to(be(true)) }
    end
  end

  it('main form updates its model and the models in nested sub-forms') do
    survey = surveys(:programming)
    form = SurveyForm.new(survey)
    params = { name: 'Native languages', questions_attributes: { '0' => { content: 'Which language is spoken in England?', id: questions(:one).id, answers_attributes: { '0' => { content: 'The English Language', id: answers(:ruby).id }, '1' => { content: 'The Latin Language', id: answers(:cs).id } } } } }
    form.submit(params)
    expect { form.save }.to_not(change(Survey, :count))
    expect(form.name).to(eq('Native languages'))
    expect(form.questions[0].content).to(eq('Which language is spoken in England?'))
    expect(form.questions[0].answers[0].content).to(eq('The Latin Language'))
    expect(form.questions[0].answers[1].content).to(eq('The English Language'))
    expect(form.questions.size).to(eq(1))
  end

  it('main form updates its model and saves dynamically added models in nested sub-forms') do
    survey = surveys(:programming)
    form = SurveyForm.new(survey)
    params = { name: 'Native languages', questions_attributes: { '0' => { content: 'Which language is spoken in England?', id: questions(:one).id, answers_attributes: { '0' => { content: 'The English Language', id: answers(:ruby).id }, '1' => { content: 'The Latin Language', id: answers(:cs).id } } }, '1404292088779' => { content: 'Which language is spoken in America?', answers_attributes: { '0' => { content: 'The English Language' }, '1' => { content: 'The American Language' } } } } }
    form.submit(params)
    expect { form.save }.to_not(change(Survey, :count))
    expect(form.name).to(eq('Native languages'))
    expect(form.questions[0].content).to(eq('Which language is spoken in England?'))
    expect(form.questions[0].answers[0].content).to(eq('The Latin Language'))
    expect(form.questions[0].answers[1].content).to(eq('The English Language'))
    expect(form.questions[1].content).to(eq('Which language is spoken in America?'))
    expect(form.questions[1].answers[0].content).to(eq('The English Language'))
    expect(form.questions[1].answers[1].content).to(eq('The American Language'))
    expect(form.questions.size).to(eq(2))
  end

  it('main form deletes models in nested sub-forms') do
    survey = surveys(:programming)
    form = SurveyForm.new(survey)
    params = { name: 'Native languages', questions_attributes: { '0' => { content: 'Which language is spoken in England?', id: questions(:one).id, answers_attributes: { '0' => { content: 'The English Language', id: answers(:ruby).id }, '1' => { :content => 'The Latin Language', :id => answers(:cs).id, '_destroy' => '1' } } } } }
    form.submit(params)
    expect(survey.questions[0].answers[0].marked_for_destruction?).to(be(true))
    expect { form.save }.to_not(change(Survey, :count))
    expect(form.name).to(eq('Native languages'))
    expect(form.questions[0].content).to(eq('Which language is spoken in England?'))
    expect(form.questions[0].answers[0].content).to(eq('The English Language'))
    expect(form.questions.size).to(eq(1))
    expect(form.questions[0].answers.size).to(eq(1))
  end

  it('main form deletes and adds models in nested sub-forms') do
    survey = surveys(:programming)
    form = SurveyForm.new(survey)
    params = { name: 'Native languages', questions_attributes: { '0' => { :content => 'Which language is spoken in England?', :id => questions(:one).id, '_destroy' => '1', :answers_attributes => { '0' => { content: 'The English Language', id: answers(:ruby).id }, '1' => { content: 'The Latin Language', id: answers(:cs).id } } }, '1404292088779' => { content: 'Which language is spoken in America?', answers_attributes: { '0' => { content: 'The English Language' }, '1' => { content: 'The American Language' }, '1404292088777' => { content: 'The French Language' } } } } }
    form.submit(params)
    expect { form.save }.to_not(change(Survey, :count))
    expect(form.name).to(eq('Native languages'))
    expect(form.questions[0].content).to(eq('Which language is spoken in America?'))
    expect(form.questions[0].answers[0].content).to(eq('The English Language'))
    expect(form.questions[0].answers[1].content).to(eq('The American Language'))
    expect(form.questions[0].answers[2].content).to(eq('The French Language'))
    expect(form.questions.size).to(eq(1))
    expect(form.questions[0].answers.size).to(eq(3))
  end

  it('main form responds to writer method') do
    assert_respond_to(@form, :questions_attributes=)
  end

  it('questions form responds to writer method') do
    @form.questions.each do |question_form|
      assert_respond_to(question_form, :answers_attributes=)
    end
  end
end
