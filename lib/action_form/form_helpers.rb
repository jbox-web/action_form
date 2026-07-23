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
        raise ArgumentError.new("No association #{assoc_name} declared in #{self.class}") if form.nil?

        form.submit(attributes)
      end

      ATTRIBUTES_KEY_REGEXP = /^(.+)_attributes$/
      private_constant :ATTRIBUTES_KEY_REGEXP

      def find_association_name_in(key)
        match = ATTRIBUTES_KEY_REGEXP.match(key)
        raise ArgumentError.new("#{key} is not a nested-attributes key (expected <association>_attributes)") if match.nil?

        match[1]
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

  end
end
