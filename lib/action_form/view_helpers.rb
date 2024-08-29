# frozen_string_literal: true

module ActionForm
  module ViewHelpers

    def link_to_remove_association(name, form, html_options = {}, &block) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      classes = []
      classes << 'remove_fields'

      is_existing = form.object.persisted?
      classes << (is_existing ? 'existing' : 'dynamic')

      wrapper_class = html_options.delete(:wrapper_class)
      html_options[:class] = [html_options[:class], classes.join(' ')].compact.join(' ')
      html_options[:'data-wrapper-class'] = wrapper_class if wrapper_class.present?

      if is_existing
        form.hidden_field(:_destroy) + build_link(name, html_options, block)
      else
        build_link(name, html_options, block)
      end
    end

    def link_to_add_association(name, form, association, html_options = {}, &block) # rubocop:disable Metrics/AbcSize
      render_options = html_options.delete(:render_options)
      render_options ||= {}
      override_partial = html_options.delete(:partial)

      html_options[:class] = [html_options[:class], 'add_fields'].compact.join(' ')
      html_options[:'data-association'] = association.to_s

      new_object = create_object(form, association)
      template   = render_association(association, form, new_object, render_options, override_partial).to_str

      html_options[:'data-association-insertion-template'] = CGI.escapeHTML(template).html_safe

      build_link(name, html_options, block)
    end

    private

      def build_link(name, html_options, block)
        if block
          link_to('#', html_options, &block)
        else
          link_to(name, '#', html_options)
        end
      end

      def create_object(form, association)
        form.object.get_model(association)
      end

      def render_association(association, form, new_object, render_options = {}, custom_partial = nil) # rubocop:disable Metrics/MethodLength
        partial = get_partial_path(custom_partial, association)

        method_name =
          if form.respond_to?(:semantic_fields_for)
            :semantic_fields_for
          elsif form.respond_to?(:simple_fields_for)
            :simple_fields_for
          else
            :fields_for
          end

        form.send(method_name, association, new_object, { child_index: "new_#{association}" }.merge(render_options)) do |builder|
          render(partial: partial, locals: { f: builder })
        end
      end

      def get_partial_path(partial, association)
        partial || "#{association.to_s.singularize}_fields"
      end

  end
end
