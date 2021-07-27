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

        def self.current_resource_from_params(current_intake, params)
          current_intake.dependents.find { |d| d.id == params[:id].to_i }
        end

        def self.model_for_show_check(current_controller)
          current_controller.current_resource || (last_edited_resource_id(current_controller) ? current_controller.visitor_record.dependents.find { |d| d.id == last_edited_resource_id(current_controller) } : nil)
        end

        def edit
          return if form_class == NullForm

          @form = form_class.from_dependent(current_resource)
        end

        def current_resource
          @dependent ||= self.class.current_resource_from_params(current_intake, params)
          raise ActiveRecord::RecordNotFound unless @dependent
          @dependent
        end

        private

        def initialized_update_form
          form_class.new(current_resource, form_params)
        end

        def remember_last_edited_dependent_id
          session[:last_edited_dependent_id] = @dependent&.id
        end
      end
    end
  end
end
