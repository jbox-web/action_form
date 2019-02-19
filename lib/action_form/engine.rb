# frozen_string_literal: true

module ActionForm
  class Engine < ::Rails::Engine

    initializer 'action_form.initialize' do
      ActiveSupport.on_load(:action_view) do
        include ActionForm::ViewHelpers
      end
    end

  end
end
