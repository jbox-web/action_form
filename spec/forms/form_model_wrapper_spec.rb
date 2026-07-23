# frozen_string_literal: true

require 'spec_helper'

# Coverage for the translation/validation "backend" selection in FormModelWrapper
# (form_model_wrapper.rb:34-46): the wrapper routes human_attribute_name to either the
# form or the model depending on i18n_form, and always delegates validators_on to the form.
RSpec.describe('FormModelWrapper') do

  fixtures(:users)

  let(:model) { User.new }
  let(:form)  { UserFormFixture.new(model) }

  it('delegates human_attribute_name to the model when i18n_form is false') do
    wrapper = ActionForm::FormModelWrapper.new(form: form, model: model, i18n_form: false)

    expect(wrapper.human_attribute_name(:name)).to(eq(User.human_attribute_name(:name)))
  end

  it('delegates human_attribute_name to the form when i18n_form is true') do
    wrapper = ActionForm::FormModelWrapper.new(form: form, model: model, i18n_form: true)

    expect(wrapper.human_attribute_name(:name)).to(eq(UserFormFixture.human_attribute_name(:name)))
  end

  # validators_on drives the required-field asterisks rendered by form builders.
  it('delegates validators_on to the form') do
    wrapper = ActionForm::FormModelWrapper.new(form: form, model: model)

    expect(wrapper.validators_on(:name)).to(eq(UserFormFixture.validators_on(:name)))
    expect(wrapper.validators_on(:name)).to_not(be_empty)
  end

end
