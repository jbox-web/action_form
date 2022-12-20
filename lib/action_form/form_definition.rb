# frozen_string_literal: true

module ActionForm
  class FormDefinition
    # *parent* is set by *populate_forms* when building final form object
    attr_accessor :parent

    # association_name is read by *populate_forms* to register the form object
    attr_reader :association_name

    def initialize(association_name, block, options = {})
      @association_name = association_name
      @proc             = block
      @records          = options[:records]
    end

    def to_form
      case association_reflection.macro
      when :has_one, :belongs_to
        Form.new(@association_name, parent, @proc)
      when :has_many
        FormCollection.new(@association_name, parent, @proc, { records: @records })
      end
    end

    private

      def association_reflection
        parent.class.reflect_on_association(@association_name)
      end

  end
end
