# frozen_string_literal: true

module ActionForm
  class FormModelWrapper < SimpleDelegator

    def initialize(form:, model:, i18n_form: false)
      @form      = form
      @model     = model
      @i18n_form = i18n_form

      # Delegate all methods to @form
      super(@form)
    end

    # Delegate AR methods to model
    delegate :new_record?, :deleted?, :persisted?,
             :to_key, :to_param, :to_partial_path,
             :==,
             to: :@model

    # Use the right model informations to build forms.
    # It should respond to: param_key, route_key, singular_route_key, name, human, i18n_key
    def model_name
      ActiveModel::Name.new(@model.class)
    end

    # Return self so we can intercept class methods calls at the instance level
    # like *human_attribute_name* or *validators_on* below
    def class
      self
    end

    # Select form translation "backend" (form or model?)
    def human_attribute_name(*args)
      if @i18n_form
        @form.class.human_attribute_name(*args)
      else
        @model.class.human_attribute_name(*args)
      end
    end

    # Form is in charge of validation (presence, etc...) so delegate *validators_on* to it.
    # This method is used to render little asterisks (required: true) in forms.
    def validators_on(*args)
      @form.class.validators_on(*args)
    end
  end
end
