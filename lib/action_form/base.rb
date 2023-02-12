# frozen_string_literal: true

module ActionForm
  class Base
    # Acts as an ActiveModel
    include ActiveModel::Model

    # Include forms common methods (submit)
    include FormHelpers

    # Use callbacks to update forms
    extend ActiveModel::Callbacks

    # Include ActiveModel::Validations::Callbacks so we can use *before_validation* in our forms
    include ActiveModel::Validations::Callbacks

    # Create after_save callbacks
    define_model_callbacks :save, only: [:after]
    after_save :update_form_models

    class << self
      attr_writer :main_model, :main_class

      def main_model
        @main_model ||= name.sub(/Form$/, '').singularize
      end

      def main_class
        @main_class ||= main_model.to_s.camelize.constantize
      end

      delegate :reflect_on_association, to: :main_class

      # Store associated forms definitions
      def forms
        @forms ||= []
      end

      # Form DSL method
      def attributes(*names)
        options = names.pop if names.last.is_a?(Hash)

        if options && options[:required]
          validates_presence_of(*names)
        end

        names.each do |attribute|
          delegate attribute, "#{attribute}=", to: :model
        end
      end
      alias_method :attribute, :attributes

      # Form DSL method
      def association(name, options = {}, &block)
        # store form definition in an object
        forms << FormDefinition.new(name, block, options)

        # generate accessors for associations
        macro = main_class.reflect_on_association(name).macro

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

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}_attributes=; end
        RUBY
      end

      def virtual_attributes(*attributes)
        attributes.each do |attribute|
          attr_accessor attribute
        end
      end
      alias_method :virtual_attribute, :virtual_attributes

    end

    # Create some accesors
    attr_reader :model, :forms

    # This object will be passed to *form_for*
    delegate :new_record?, :deleted?, :persisted?,
             :to_key, :to_param, :to_partial_path,
             to: :@model

    def initialize(model)
      @model = model
      @forms = []
      populate_forms
    end

    def save
      if valid?
        run_callbacks :save do
          ActiveRecord::Base.transaction do
            model.save
          end
        end
      else
        false
      end
    end

    def save!
      save or raise ActiveRecord::RecordInvalid.new(self)
    end

    # used by view helper to add/remove associations
    def get_model(association_name)
      form = find_form_by_assoc_name(association_name)
      form.get_model(association_name)
    end

    if ActionForm.rails_buggy?
      def to_model
        FormModelWrapper.new(form: self, model: model)
      end
    else
      def to_model
        @model
      end
    end

    private

      def populate_forms
        self.class.forms.each do |definition|
          # set parent model on FormDefinition
          definition.parent = @model

          # build final Form object
          nested_form = definition.to_form
          form_name   = definition.association_name

          # save form object
          @forms << nested_form
          instance_variable_set("@#{form_name}", nested_form)
        end
      end

      def update_form_models
        @forms.map(&:update_models)
      end

  end
end
