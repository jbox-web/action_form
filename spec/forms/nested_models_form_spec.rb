# frozen_string_literal: true

require 'spec_helper'

RSpec.describe('NestedModelsForm') do

  fixtures(:users, :emails, :profiles)

  before do
    @user = User.new
    @form = UserForm.new(@user)
    @profile_form = @form.profile
    @model = @form
  end

  it('declares both sub-forms') do
    expect(UserForm.forms.size).to(eq(2))
    expect(@form.forms.size).to(eq(2))
  end

  it('forms list contains profile sub-form definition') do
    profile_definition = UserForm.forms.last
    expect(profile_definition.association_name).to(eq(:profile))
  end

  it('profile sub-form contains association name and parent') do
    expect(@profile_form.association_name).to(eq(:profile))
    expect(@profile_form.parent).to(eq(@user))
  end

  it('profile sub-form declares attributes') do
    attributes = %i[twitter_name twitter_name= github_name github_name=]
    attributes.each { |attribute| assert_respond_to(@profile_form, attribute) }
  end

  it('profile sub-form delegates attributes to model') do
    @profile_form.twitter_name = 'twitter_peter'
    @profile_form.github_name = 'github_peter'
    expect(@profile_form.twitter_name).to(eq('twitter_peter'))
    expect(@profile_form.model.twitter_name).to(eq('twitter_peter'))
    expect(@profile_form.github_name).to(eq('github_peter'))
    expect(@profile_form.model.github_name).to(eq('github_peter'))
  end

  it('profile sub-form initializes model for new parent') do
    expect(@profile_form.model).to(be_instance_of(Profile))
    expect(@profile_form.model).to(eq(@form.model.profile))
    expect(@profile_form.model.new_record?).to(be(true))
  end

  it('profile sub-form fetches model for existing parent') do
    user = users(:peter)
    user_form = UserForm.new(user)
    profile_form = user_form.profile
    expect(profile_form.model).to(be_instance_of(Profile))
    expect(profile_form.model).to(eq(user_form.model.profile))
    expect(profile_form.persisted?).to(be(true))
    expect(user_form.name).to(eq('m-peter'))
    expect(user_form.age).to(eq(23))
    expect(user_form.gender).to(eq(0))
    expect(profile_form.model.twitter_name).to(eq('twitter_peter'))
    expect(profile_form.model.github_name).to(eq('github_peter'))
  end

  it('profile sub-form validates itself') do
    @profile_form.twitter_name = nil
    @profile_form.github_name = nil
    expect(@profile_form.valid?).to(be(false))
    %i[twitter_name github_name].each do |attribute|
      expect(@profile_form.errors.messages[attribute]).to include("can't be blank")
    end
    @profile_form.twitter_name = 't-peter'
    @profile_form.github_name = 'g-peter'
    expect(@profile_form.valid?).to(be(true))
  end

  it('main form syncs its model and the models in nested sub-forms') do
    params = { name: 'Petrakos', age: '23', gender: '0', email_attributes: { address: 'petrakos@gmail.com' }, profile_attributes: { twitter_name: 't_peter', github_name: 'g_peter' } }
    @form.submit(params)
    expect(@form.name).to(eq('Petrakos'))
    expect(@form.age).to(eq(23))
    expect(@form.gender).to(eq(0))
    expect(@form.email.address).to(eq('petrakos@gmail.com'))
    expect(@profile_form.twitter_name).to(eq('t_peter'))
    expect(@profile_form.github_name).to(eq('g_peter'))
  end

  it('main form saves its model and the models in nested sub-forms') do
    params = { name: 'Petrakos', age: '23', gender: '0', email_attributes: { address: 'petrakos@gmail.com' }, profile_attributes: { twitter_name: 't_peter', github_name: 'g_peter' } }
    @form.submit(params)
    expect { @form.save }.to change(User, :count).by(1).and change(Email, :count).by(1).and change(Profile, :count).by(1)
    expect(@form.name).to(eq('Petrakos'))
    expect(@form.age).to(eq(23))
    expect(@form.gender).to(eq(0))
    expect(@form.email.address).to(eq('petrakos@gmail.com'))
    expect(@profile_form.twitter_name).to(eq('t_peter'))
    expect(@profile_form.github_name).to(eq('g_peter'))
    expect(@form.persisted?).to(be(true))
    expect(@form.email.persisted?).to(be(true))
    expect(@profile_form.persisted?).to(be(true))
  end

  it('main form updates its model and the models in nested sub-forms') do
    user = users(:peter)
    form = UserForm.new(user)
    params = { name: 'Petrakos', age: 24, gender: 0, email_attributes: { address: 'cs3199@teilar.gr' }, profile_attributes: { twitter_name: 'peter_t', github_name: 'peter_g' } }
    form.submit(params)
    expect { form.save }.to change(User, :count).by(0).and change(Email, :count).by(0)
    expect(form.name).to(eq('Petrakos'))
    expect(form.age).to(eq(24))
    expect(form.gender).to(eq(0))
    expect(form.email.address).to(eq('cs3199@teilar.gr'))
    expect(form.profile.twitter_name).to(eq('peter_t'))
    expect(form.profile.github_name).to(eq('peter_g'))
  end

  it('main form collects all the model related errors') do
    peter = users(:peter)
    params = { name: peter.name, age: '23', gender: '0', email_attributes: { address: peter.email.address }, profile_attributes: { twitter_name: peter.profile.twitter_name, github_name: peter.profile.github_name } }
    @form.submit(params)
    expect { @form.save }.to change(User, :count).by(0).and change(Email, :count).by(0).and change(Profile, :count).by(0)
    expect(@form.errors[:name]).to include('has already been taken')
    expect(@form.errors['email.address']).to include('has already been taken')
    expect(@form.errors['profile.twitter_name']).to include('has already been taken')
    expect(@form.errors['profile.github_name']).to include('has already been taken')
  end

  it('main form collects all the form specific errors') do
    params = { name: nil, age: nil, gender: nil, email_attributes: { address: nil }, profile_attributes: { twitter_name: nil, github_name: nil } }
    @form.submit(params)
    expect(@form.valid?).to(be(false))
    expect(@form.errors[:name]).to include("can't be blank")
    expect(@form.errors[:age]).to include("can't be blank")
    expect(@form.errors[:gender]).to include("can't be blank")
    expect(@form.errors['email.address']).to include("can't be blank")
    expect(@form.errors['profile.twitter_name']).to include("can't be blank")
    expect(@form.errors['profile.github_name']).to include("can't be blank")
  end

  it('main form responds to writer method') do
    assert_respond_to(@form, :email_attributes=)
    assert_respond_to(@form, :profile_attributes=)
  end
end
