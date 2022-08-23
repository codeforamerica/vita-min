module Ctc
  module Questions
    module W2s
      class BaseW2Controller < QuestionsController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.resource_name
          :w2s
        end

        def self.form_key
          "ctc/w2s/" + controller_name + "_form"
        end

        def self.current_resource_from_params(current_intake, params)
          current_intake.w2s.find { |d| d.id == params[:id].to_i }
        end
        #
        # def self.model_for_show_check(current_controller)
        #   current_controller.current_resource || (last_edited_resource_id(current_controller) ? current_controller.visitor_record.dependents.find { |d| d.id == last_edited_resource_id(current_controller) } : nil)
        # end

        def edit
          return if form_class == NullForm

          @form = form_class.from_w2(current_resource)
        end

        def current_resource
          @w2 ||= self.class.current_resource_from_params(current_intake, params)
          raise ActiveRecord::RecordNotFound unless @w2
          @w2
        end
      end
    end
  end
end
