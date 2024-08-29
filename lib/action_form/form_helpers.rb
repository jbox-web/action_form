# frozen_string_literal: true

module ActionForm
  module FormHelpers

    def submit(params)
      params.each do |key, value|
        if nested_params?(value)
          fill_association_with_attributes(key, value)
        else
          public_send(:"#{key}=", value)
        end
      end
    end

    def valid?
      # call ActiveModel validation (*validates* in form objects)
      super

      # trigger model validation (*validates* in model objects)
      model.valid?

      # collect errors
      collect_errors_from(model)
      aggregate_form_errors(@forms)

      # return true or false
      errors.empty?
    end

    private

      def nested_params?(value)
        value.is_a?(Hash) || value.is_a?(ActionController::Parameters)
      end

      def fill_association_with_attributes(association, attributes)
        assoc_name = find_association_name_in(association).to_sym
        form = find_form_by_assoc_name(assoc_name)
        form.submit(attributes)
      end

      ATTRIBUTES_KEY_REGEXP = /^(.+)_attributes$/
      private_constant :ATTRIBUTES_KEY_REGEXP

      def find_association_name_in(key)
        ATTRIBUTES_KEY_REGEXP.match(key)[1]
      end

      def find_form_by_assoc_name(assoc_name)
        @forms.find { |form| form.represents?(assoc_name) }
      end

      def aggregate_form_errors(forms)
        forms.each do |form|
          form.valid?
          collect_errors_from(form)
        end
      end

      if ActionForm.rails_error_object?
        def collect_errors_from(validatable_object)
          validatable_object.errors.each do |error|
            key =
              if validatable_object.respond_to?(:association_name)
                "#{validatable_object.association_name}.#{error.attribute}"
              else
                error.attribute
              end

            errors.add(key, error.message)
          end
        end
      else
        def collect_errors_from(validatable_object)
          validatable_object.errors.each do |attribute, error|
            key =
              if validatable_object.respond_to?(:association_name)
                "#{validatable_object.association_name}.#{attribute}"
              else
                attribute
              end

            errors.add(key, error)
          end
        end
      end

  end
end
