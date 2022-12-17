# frozen_string_literal: true

module ActionForm
  class Base
    include ActiveModel::Model
    include FormHelpers
    extend ActiveModel::Callbacks

    # Include ActiveModel::Validations::Callbacks so we can use *before_validation* in our forms
    include ActiveModel::Validations::Callbacks

    define_model_callbacks :save, only: [:after]
    after_save :update_form_models

    attr_reader :model, :forms

    delegate :new_record?, :deleted?, :persisted?, :to_key, :to_param, :to_partial_path, to: :model

    def initialize(model)
      @model = model
      @forms = []
      populate_forms
    end

    def get_model(assoc_name)
      form = find_form_by_assoc_name(assoc_name)
      form.get_model(assoc_name)
    end

    def save!
      save or raise ActiveRecord::RecordInvalid.new(self)
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

    class FormModelWrapper < SimpleDelegator
      class FakeName
        def initialize(model)
          @klass = model.class
        end

        def param_key
          ActiveModel::Naming.param_key(@klass)
        end

        def route_key
          ActiveModel::Naming.route_key(@klass)
        end

        def singular_route_key
          ActiveModel::Naming.singular_route_key(@klass)
        end

        def name
          @klass.model_name.name
        end

        def human
          @klass.model_name.human
        end

        def i18n_key
          @klass.model_name.i18n_key
        end
      end

      class << self

        attr_reader :form, :model

        def for(form:, model:, i18n_form: false)
          @form  = form
          @model = model
          @i18n_form = i18n_form
          new(form, model)
        end

        def i18n_form?
          @i18n_form
        end

        def human_attribute_name(*args)
          if i18n_form?
            form.class.human_attribute_name(*args)
          else
            model.class.human_attribute_name(*args)
          end
        end

        def validators_on(*args)
          form.class.validators_on(*args)
        end

      end

      def initialize(form, model)
        @form = form
        @model = model
        super(@form)
      end

      delegate :new_record?, :deleted?, :persisted?,
               :to_key, :to_param, :to_partial_path,
               :==,
               to: :@model

      def model_name
        FakeName.new(@model)
      end
    end

    def to_model
      FormModelWrapper.for(form: self, model: model)
    end

    class << self
      attr_writer :main_class, :main_model
      delegate :reflect_on_association, to: :main_class

      def attributes(*names)
        options = names.pop if names.last.is_a?(Hash)

        if options && options[:required]
          validates_presence_of(*names)
        end

        names.each do |attribute|
          delegate attribute, "#{attribute}=", to: :model
        end
      end

      def main_class
        @main_class ||= main_model.to_s.camelize.constantize
      end

      def main_model
        @main_model ||= name.sub(/Form$/, '').singularize
      end

      alias_method :attribute, :attributes

      def association(name, options = {}, &block)
        forms << FormDefinition.new(name, block, options)
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

      def forms
        @forms ||= []
      end
    end

    private

    def update_form_models
      forms.map(&:update_models)
    end

    def populate_forms
      self.class.forms.each do |definition|
        definition.parent = model
        nested_form = definition.to_form
        forms << nested_form
        name = definition.assoc_name
        instance_variable_set("@#{name}", nested_form)
      end
    end

  end
end
