# frozen_string_literal: true

require 'spec_helper'

RSpec.describe('NestedModelForm') do

  fixtures(:users, :emails)

  before do
    @user = User.new
    @form = UserWithEmailFormFixture.new(@user)
    @email_form = @form.email
    @model = @form
  end

  it('declares association') do
    assert_respond_to(UserWithEmailFormFixture, :association)
  end

  it('contains a list of sub-forms') do
    assert_respond_to(UserWithEmailFormFixture, :forms)
  end

  it('forms list contains form definitions') do
    email_definition = UserWithEmailFormFixture.forms.first
    expect(email_definition.association_name).to(eq(:email))
  end

  it('contains getter for email sub-form') do
    assert_respond_to(@form, :email)
    expect(@form.email).to(be_instance_of(ActionForm::Form))
  end

  it('email sub-form contains association name and parent model') do
    expect(@email_form.association_name).to(eq(:email))
    expect(@email_form.parent).to(eq(@user))
  end

  it('email sub-form initializes model for new parent') do
    expect(@email_form.model).to(be_instance_of(Email))
    expect(@email_form.model).to(eq(@form.model.email))
    expect(@email_form.model.new_record?).to(be(true))
  end

  it('email sub-form fetches model for existing parent') do
    user = users(:peter)
    user_form = UserWithEmailFormFixture.new(user)
    email_form = user_form.email
    expect(email_form.model).to(be_instance_of(Email))
    expect(email_form.model).to(eq(user_form.model.email))
    expect(email_form.persisted?).to(be(true))
    expect(user_form.name).to(eq('m-peter'))
    expect(user_form.age).to(eq(23))
    expect(user_form.gender).to(eq(0))
    expect(email_form.address).to(eq('markoupetr@gmail.com'))
  end

  it("#represents? returns true if the argument matches the Form's association name, false otherwise") do
    expect(@email_form.represents?('email')).to(be(true))
    expect(@email_form.represents?('profile')).to(be(false))
  end

  it('email sub-form declares attributes') do
    %i[address address=].each do |attribute|
      assert_respond_to(@email_form, attribute)
    end
  end

  it('email sub-form delegates attributes to model') do
    @email_form.address = 'petrakos@gmail.com'
    expect(@email_form.address).to(eq('petrakos@gmail.com'))
    expect(@email_form.model.address).to(eq('petrakos@gmail.com'))
  end

  it('email sub-form validates itself') do
    @email_form.address = nil
    expect(@email_form.valid?).to(be(false))
    expect(@email_form.errors.messages[:address]).to include("can't be blank")
    @email_form.address = 'petrakos@gmail.com'
    expect(@email_form.valid?).to(be(true))
  end

  it('email sub-form validates the model') do
    existing_email = emails(:peters)
    @email_form.address = existing_email.address
    expect(@email_form.valid?).to(be(false))
    expect(@email_form.errors.messages[:address]).to include('has already been taken')
    @email_form.address = 'petrakos@gmail.com'
    expect(@email_form.valid?).to(be(true))
  end

  it('email sub-form can use validates method') do
    params = { name: 'Petrakos', age: '23', gender: '0', email_attributes: { address: 'petrakos1@gmail.com' } }
    @form.submit(params)
    expect(@form.valid?).to(be(false))
    expect(@form.errors.messages[:'email.address']).to include('is too long (maximum is 18 characters)')
  end

  it('email sub-form can use validate method') do
    params = { name: 'Petrakos', age: '23', gender: '0', email_attributes: { address: 'petrakos1@gmail.com' } }
    @form.submit(params)
    expect(@form.valid?).to(be(false))
    expect(@form.errors.messages[:'email.address']).to include('is invalid')
  end

  it('main form can use validate method') do
    params = { name: 'Petrakos1', age: '23', gender: '0', email_attributes: { address: 'petrakos@gmail.com' } }
    @form.submit(params)
    expect(@form.valid?).to(be(false))
    expect(@form.errors.messages[:name]).to include('is invalid')
  end

  it('main form syncs its model and the models in nested sub-forms') do
    params = { name: 'Petrakos', age: '23', gender: '0', email_attributes: { address: 'petrakos@gmail.com' } }
    @form.submit(params)
    expect(@form.name).to(eq('Petrakos'))
    expect(@form.age).to(eq(23))
    expect(@form.gender).to(eq(0))
    expect(@email_form.address).to(eq('petrakos@gmail.com'))
  end

  it('main form saves its model and the models in nested sub-forms') do
    params = { name: 'Petrakos', age: '23', gender: '0', email_attributes: { address: 'petrakos@gmail.com' } }
    @form.submit(params)
    # assert_difference(["User.count", "Email.count"]) { @form.save }
    expect { @form.save }.to change(User, :count).and change(Email, :count)
    expect(@form.name).to(eq('Petrakos'))
    expect(@form.age).to(eq(23))
    expect(@form.gender).to(eq(0))
    expect(@email_form.address).to(eq('petrakos@gmail.com'))
    expect(@form.persisted?).to(be(true))
    expect(@email_form.persisted?).to(be(true))
  end

  it('main form updates its model and the models in nested sub-forms') do
    user = users(:peter)
    form = UserWithEmailFormFixture.new(user)
    params = { name: 'Petrakos', age: 24, gender: 0, email_attributes: { address: 'cs3199@teilar.gr' } }
    form.submit(params)
    # assert_difference(["User.count", "Email.count"], 0) { form.save }
    expect { form.save }.to change(User, :count).by(0).and change(Email, :count).by(0)
    expect(form.name).to(eq('Petrakos'))
    expect(form.age).to(eq(24))
    expect(form.gender).to(eq(0))
    expect(form.email.address).to(eq('cs3199@teilar.gr'))
  end

  it('main form collects all the model related errors') do
    peter = users(:peter)
    params = { name: peter.name, age: '23', gender: '0', email_attributes: { address: peter.email.address } }
    @form.submit(params)
    # assert_difference(["User.count", "Email.count"], 0) { @form.save }
    expect { @form.save }.to change(User, :count).by(0).and change(Email, :count).by(0)
    expect(@form.errors[:name]).to include('has already been taken')
    expect(@form.errors['email.address']).to include('has already been taken')
  end

  it('main form collects all the form specific errors') do
    params = { name: nil, age: nil, gender: nil, email_attributes: { address: nil } }
    @form.submit(params)
    expect(@form.valid?).to(be(false))
    expect(@form.errors[:name]).to include("can't be blank")
    expect(@form.errors[:age]).to include("can't be blank")
    expect(@form.errors[:gender]).to include("can't be blank")
    expect(@form.errors['email.address']).to include("can't be blank")
  end

  it('main form responds to writer method') do
    assert_respond_to(@form, :email_attributes=)
  end
end
