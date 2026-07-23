# frozen_string_literal: true

module ActionForm
  class FormCollection # rubocop:disable Metrics/ClassLength
    include ActiveModel::Validations

    attr_reader :association_name, :parent, :proc, :records, :forms

    def initialize(association_name, parent, proc, options)
      @association_name = association_name
      @parent           = parent
      @proc             = proc
      @records          = options[:records] || 1
      @forms            = []

      assign_forms
    end

    def submit(params)
      enforce_records_limit(params) unless parent.persisted?

      params.each do |key, value|
        value = value.to_h if value.is_a?(ActionController::Parameters)
        if parent.persisted?
          create_or_update_record(value)
        else
          create_or_assign_record(key, value)
        end
      end
    end

    def valid?
      aggregate_form_errors(@forms)
      errors.empty?
    end

    def represents?(assoc_name)
      association_name.to_s == assoc_name.to_s
    end

    def update_models
      @forms = []
      fetch_models
    end

    def models
      @forms
    end

    def each(&block)
      @forms.each(&block)
    end

    # used by view helper to add/remove associations
    def get_model(_assoc_name)
      Form.new(association_name, parent, proc)
    end

    private

      def assign_forms
        if parent.persisted?
          fetch_models
        else
          initialize_models
        end
      end

      def fetch_models
        associated_records = parent.public_send(association_name)

        associated_records.each do |model|
          form = Form.new(association_name, parent, proc, model)
          @forms << form
        end
      end

      def initialize_models
        records.times do
          form = Form.new(association_name, parent, proc)
          @forms << form
        end
      end

      def create_or_update_record(attributes)
        if existing_record?(attributes)
          update_record(attributes)
        elsif !call_reject_if(attributes)
          # Symmetrically with the non-persisted path (*create_or_assign_record*), an
          # all-blank new nested row is rejected instead of persisted as an empty record.
          create_record(attributes)
        end
      end

      def existing_record?(attributes)
        attributes[:id] != nil
      end

      def create_record(attributes)
        new_form = create_form
        new_form.submit(attributes)
      end

      def create_form
        new_form = Form.new(association_name, parent, proc)
        @forms << new_form
        new_form
      end

      def update_record(attributes)
        id = attributes[:id]
        form = find_form_by_model_id(id)

        # A submitted id that matches none of the loaded child forms (tampered hidden
        # field, or a record removed since the form was rendered) must raise a defined
        # error, as accepts_nested_attributes_for does, not a NoMethodError on nil.
        if form.nil?
          klass = parent.class.reflect_on_association(association_name).klass
          raise ActiveRecord::RecordNotFound.new("Couldn't find #{klass} with ID=#{id} for #{parent.class}")
        end

        assign_to_or_mark_for_destruction(form, attributes)
      end

      def find_form_by_model_id(id)
        @forms.find { |form| form.id == id.to_i }
      end

      UNASSIGNABLE_KEYS = %w[id _destroy].freeze
      private_constant :UNASSIGNABLE_KEYS

      def assign_to_or_mark_for_destruction(form, attributes)
        form.submit(attributes.except(*UNASSIGNABLE_KEYS))

        return unless destroy_flag?(attributes)

        form.delete
        remove_form(form)
      end

      def destroy_flag?(attributes)
        attributes['_destroy'] == '1'
      end

      def remove_form(form)
        @forms.delete(form)
      end

      def create_or_assign_record(key, attributes)
        i = key.to_i

        if dynamic_key?(i)
          create_record(attributes)
        else
          @forms[i].delete if call_reject_if(attributes)
          @forms[i].submit(attributes)
        end
      end

      def dynamic_key?(key)
        key >= @forms.size
      end

      # For a not-yet-persisted parent, *records* rows are pre-built with sequential keys
      # (0..records-1). Rows added dynamically by *link_to_add_association* carry a timestamp
      # key, far above the submitted count, so they never look sequential. Submitting more
      # sequential rows than *records* means the caller sent more than the form allows.
      def enforce_records_limit(params)
        submitted  = params.keys.size
        sequential = params.keys.count { |key| key.to_i < submitted }
        return if sequential <= records

        raise TooManyRecords.new("Maximum #{records} records are allowed. Got #{submitted} records instead.")
      end

      REJECT_ALL_BLANK_PROC = proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }
      private_constant :REJECT_ALL_BLANK_PROC

      def call_reject_if(attributes)
        REJECT_ALL_BLANK_PROC.call(attributes)
      end

      def aggregate_form_errors(forms)
        forms.each do |form|
          form.valid?
          collect_errors_from(form)
        end
      end

      def collect_errors_from(model)
        model.errors.each do |error|
          errors.add(error.attribute, error.message)
        end
      end

  end
end
