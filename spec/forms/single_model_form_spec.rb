require 'spec_helper'

RSpec.describe('SingleModelForm') do

  fixtures(:users)

  before do
    @user = User.new
    @form = UserFormFixture.new(@user)
    @model = @form
  end

  it("accepts the model it represents") do
    expect(@form.model).to(eq(@user))
  end

  it("declares form attributes") do
    attributes = [:name, :name=, :age, :age=, :gender, :gender=]
    attributes.each { |attribute| assert_respond_to(@form, attribute) }
  end

  it("delegates attributes to the model") do
    @form.name = "Peter"
    @form.age = 23
    @form.gender = 0
    expect(@user.name).to(eq("Peter"))
    expect(@user.age).to(eq(23))
    expect(@user.gender).to(eq(0))
  end

  it("validates itself") do
    @form.name = nil
    @form.age = nil
    @form.gender = nil
    expect(@form.valid?).to(eq(false))
    [:name, :age, :gender].each do |attribute|
      assert_includes(@form.errors.messages[attribute], "can't be blank")
    end
    @form.name = "Peters"
    @form.age = 23
    @form.gender = 0
    expect(@form.valid?).to(eq(true))
  end

  it("validates the model") do
    peter = users(:peter)
    @form.name = peter.name
    @form.age = 23
    @form.gender = 0
    expect(@form.valid?).to(eq(false))
    assert_includes(@form.errors.messages[:name], "has already been taken")
  end

  it("sync the model with submitted data") do
    params = { :name => "Peters", :age => "23", :gender => "0" }
    @form.submit(params)
    expect(@form.name).to(eq("Peters"))
    expect(@form.age).to(eq(23))
    expect(@form.gender).to(eq(0))
  end

  it("sync the form with existing model") do
    peter = users(:peter)
    form = UserFormFixture.new(peter)
    expect(form.name).to(eq("m-peter"))
    expect(form.age).to(eq(23))
    expect(form.gender).to(eq(0))
  end

  it("saves the model") do
    params = { :name => "Peters", :age => "23", :gender => "0" }
    @form.submit(params)
    expect { @form.save }.to(change { User.count })
    expect(@form.name).to(eq("Peters"))
    expect(@form.age).to(eq(23))
    expect(@form.gender).to(eq(0))
  end

  it("does not save the model with invalid data") do
    peter = users(:peter)
    params = { :name => peter.name, :age => "23", :gender => nil }
    @form.submit(params)
    expect { @form.save }.to(change { User.count }.by(0))
    expect(@form.valid?).to(eq(false))
    assert_includes(@form.errors.messages[:name], "has already been taken")
    assert_includes(@form.errors.messages[:gender], "can't be blank")
  end

  it("updates the model") do
    peter = users(:peter)
    form = UserFormFixture.new(peter)
    params = { :name => "Petrakos", :age => peter.age, :gender => peter.gender }
    form.submit(params)
    expect { form.save }.to(change { User.count }.by(0))
    expect(form.name).to(eq("Petrakos"))
  end

  it("responds to #persisted?") do
    assert_respond_to(@form, :persisted?)
    expect(@form.persisted?).to(eq(false))
    expect(save_user).to(be_truthy)
    expect(@form.persisted?).to(eq(true))
  end

  it("responds to #to_key") do
    assert_respond_to(@form, :to_key)
    expect(@form.to_key).to(be_nil)
    expect(save_user).to(be_truthy)
    expect(@form.to_key).to(eq(@user.to_key))
  end

  it("responds to #to_param") do
    assert_respond_to(@form, :to_param)
    expect(@form.to_param).to(be_nil)
    expect(save_user).to(be_truthy)
    expect(@form.to_param).to(eq(@user.to_param))
  end

  it("responds to #to_partial_path") do
    assert_respond_to(@form, :to_partial_path)
    expect(@form.to_partial_path).to(be_instance_of(String))
  end

  it("responds to #to_model") do
    assert_respond_to(@form, :to_model)
    expect(@form.to_model).to(eq(@user))
  end

  private

  def save_user
    @form.name = "Peters"
    @form.age = 23
    @form.gender = 0
    @form.save
  end

end
