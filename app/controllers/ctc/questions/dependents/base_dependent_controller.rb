module Ctc
  module Questions
    module Dependents
      class BaseDependentController < QuestionsController
        after_action :remember_last_edited_dependent_id

        def self.resource_name
          :dependents
        end

        def self.last_edited_resource_id(current_controller)
          current_controller.session[:last_edited_dependent_id]
        end

        def self.form_key
          "ctc/dependents/" + controller_name + "_form"
        end

        def edit
          return if form_class == NullForm

          @form = form_class.from_dependent(current_dependent)
        end

        private

        def initialized_update_form
          form_class.new(current_dependent, form_params)
        end

        def current_dependent
          @dependent ||= current_intake.dependents.find(params[:id])
        end

        def remember_last_edited_dependent_id
          session[:last_edited_dependent_id] = @dependent&.id
        end
      end
    end
  end
end
