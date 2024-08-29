# frozen_string_literal: true

require 'spec_helper'

RSpec.describe('PoroForm') do

  before do
    @poro = Poro.new
    @form = PoroFormFixture.new(@poro)
    @model = @form
  end

  it('main form validates itself') do
    params = { name: 'Euruco', city: 'Athens' }
    @form.submit(params)
    expect(@form.valid?).to(be(true))
    @form.submit(name: nil, city: nil)
    expect(@form.valid?).to(be(false))
    expect(@form.errors[:name]).to include("can't be blank")
    expect(@form.errors[:city]).to include("can't be blank")
  end

  it('save works') do
    params = { name: 'Euruco', city: 'Athens' }
    @form.submit(params)
    expect(@form.save).to(be_truthy)
  end

  it('raise error') do
    @form.submit(name: nil, city: nil)
    expect { @form.save! }.to(raise_error(ActiveRecord::RecordInvalid))
  end
end
