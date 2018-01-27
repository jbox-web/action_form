# frozen_string_literal: true

module ActionForm
  class FormDefinition
    attr_accessor :assoc_name, :proc, :parent, :records

    def initialize(assoc_name, block, options={})
      @assoc_name = assoc_name
      @proc = block
      @records = options[:records]
    end

    def to_form
      macro = association_reflection.macro

      case macro
      when :has_one, :belongs_to
        Form.new(assoc_name, parent, proc)
      when :has_many
        FormCollection.new(assoc_name, parent, proc, {records: records})
      end
    end

    private

    def association_reflection
      parent.class.reflect_on_association(@assoc_name)
    end
  end

end
