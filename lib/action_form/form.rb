# frozen_string_literal: true

module ActionForm
  class Form # rubocop:disable Metrics/ClassLength
    # Form object are validatable
    include ActiveModel::Validations

    # Include ActiveModel::Validations::Callbacks so we can use *before_validation* in our forms
    include ActiveModel::Validations::Callbacks

    # Remove *validate* instance method as it conflicts with *method_missing*
    # See: https://github.com/rails/rails/blob/main/activemodel/lib/active_model/validations.rb#L371
    undef_method :validate

    # Include forms common methods (submit)
    include FormHelpers

    # Create some getters
    attr_reader :association_name, :parent, :association_reflection, :proc, :model, :forms, :to_model

    # Be compliant with AR
    # This object will be passed to *form_for*
    delegate :new_record?, :deleted?, :persisted?,
             :id, :_destroy,
             to: :model

    delegate :model_name, to: :to_model

    class << self

      def attribute_method?(attribute)
        attributes.include?(attribute.to_sym) || super
      end

      def attributes
        @attributes ||= []
      end

    end

    def initialize(association_name, parent, proc, model = nil)
      @association_name       = association_name
      @parent                 = parent
      @association_reflection = parent.class.reflect_on_association(association_name)
      @proc                   = proc
      @model                  = assign_model(model)
      @to_model               = FormModelWrapper.new(form: self, model: @model)
      @forms                  = []

      enable_autosave
      instance_eval(&proc)
    end

    # Form DSL method
    def attribute(name, opts = {})
      self.class.attributes << name.to_sym

      class_eval do
        validates_presence_of(name) if opts[:required]
        delegate name, "#{name}=", to: :model
      end
    end

    # Form DSL method
    def association(name, options = {}, &block) # rubocop:disable Metrics/MethodLength
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
      instance_variable_set(:"@#{name}", nested_form)

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}_attributes=; end
      RUBY
    end

    def virtual_attributes(*attributes)
      class_eval do
        attributes.each do |attribute|
          attr_accessor attribute
        end
      end
    end
    alias_method :virtual_attribute, :virtual_attributes

    def submit(params)
      if association_reflection.macro == :belongs_to && !call_reject_if(params_for_current_scope(params))
        @model = parent.public_send(:"build_#{association_name}")
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

    def method_missing(method_sym, *arguments, &block) # rubocop:disable Style/MissingRespondToMissing
      # dont break existing tests
      return if method_sym == :id=

      # call validates/validate class methods
      if method_sym =~ /^validates?$/ || method_sym == :phony_normalize
        class_eval do
          public_send(method_sym, *arguments, &block)
        end
      else
        # call instance level validation methods (called from *validate* class method)
        super
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
        object.nil? ? parent.public_send(:"build_#{association_name}") : object
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
