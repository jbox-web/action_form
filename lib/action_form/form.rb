# frozen_string_literal: true

module ActionForm
  class Form
    # Form object are validatable
    include ActiveModel::Validations

    # Include forms common methods (submit)
    include FormHelpers

    # Create some getters
    attr_reader :association_name, :parent, :association_reflection, :proc, :model, :forms

    # Be compliant with AR (delegate *class* method to model to get the right translations in forms)
    # See *human_attribute_name* in FormModelWrapper
    delegate :id, :_destroy, :persisted?, :class, to: :model

    def initialize(association_name, parent, proc, model = nil)
      @association_name       = association_name
      @parent                 = parent
      @association_reflection = parent.class.reflect_on_association(association_name)
      @proc                   = proc
      @model                  = assign_model(model)
      @forms                  = []

      enable_autosave
      instance_eval(&proc)
    end

    # Form DSL method
    def attributes(*arguments)
      class_eval do
        options = arguments.pop if arguments.last.is_a?(Hash)

        if options && options[:required]
          validates_presence_of(*arguments)
        end

        arguments.each do |attribute|
          delegate attribute, "#{attribute}=", to: :model
        end
      end
    end
    alias_method :attribute, :attributes

    # Form DSL method
    def association(name, options = {}, &block)
      macro = model.class.reflect_on_association(name).macro
      form_definition = FormDefinition.new(name, block, options)
      form_definition.parent = @model

      case macro
      when :has_one, :belongs_to
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}; @#{name}; end
        RUBY
      when :has_many
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}; @#{name}.models; end
        RUBY
      end

      nested_form = form_definition.to_form
      @forms << nested_form
      instance_variable_set("@#{name}", nested_form)

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}_attributes=; end
      RUBY
    end

    def submit(params)
      if association_reflection.macro == :belongs_to
        @model = parent.public_send("build_#{association_name}") unless call_reject_if(params_for_current_scope(params))
      end

      super
    end

    def represents?(assoc_name)
      association_name.to_s == assoc_name.to_s
    end

    def update_models
      @model = parent.public_send(association_name)
    end

    def delete
      model.mark_for_destruction
    end

    def get_model(assoc_name)
      return Form.new(association_name, parent, proc) if represents?(assoc_name)

      form = find_form_by_assoc_name(assoc_name)
      form.get_model(assoc_name)
    end

    def method_missing(method_sym, *arguments, &block)
      if method_sym =~ /^validates?$/
        class_eval do
          public_send(method_sym, *arguments, &block)
        end
      end
    end

    private

      def assign_model(model)
        model.nil? ? build_model : model
      end

      def build_model
        case association_reflection.macro
        when :belongs_to
          fetch_or_initialize_model
        when :has_one
          fetch_or_build_model
        when :has_many
          parent.public_send(association_name).build
        end
      end

      def fetch_or_initialize_model
        object = parent.public_send(association_name)
        object.nil? ? association_reflection.klass.new : object
      end

      def fetch_or_build_model
        object = parent.public_send(association_name)
        object.nil? ? parent.public_send("build_#{association_name}") : object
      end

      def enable_autosave
        association_reflection.autosave = true
      end

      REJECT_ALL_BLANK_PROC = proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }
      private_constant :REJECT_ALL_BLANK_PROC

      def call_reject_if(attributes)
        REJECT_ALL_BLANK_PROC.call(attributes)
      end

      def params_for_current_scope(attributes)
        attributes.dup.reject { |_, v| v.is_a?(Hash) }
      end

  end
end
