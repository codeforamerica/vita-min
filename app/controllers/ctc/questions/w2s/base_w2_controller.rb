module Ctc
  module Questions
    module W2s
      class BaseW2Controller < QuestionsController
        include AuthenticatedCtcClientConcern
        after_action :remember_last_edited_w2_id

        layout "intake"

        def self.show?(w2, current_controller)
          return unless current_controller.open_for_eitc_intake?
          return unless w2

          intake = w2.intake
          benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)
          benefits_eligibility.claiming_and_qualified_for_eitc_pre_w2s?
        end

        def self.resource_name
          :w2s
        end

        def self.form_key
          "ctc/w2s/" + controller_name + "_form"
        end

        def self.current_resource_from_params(current_intake, params)
          current_intake.w2s_including_incomplete.find { |d| d.id == params[:id].to_i }
        end

        def self.last_edited_resource_id(current_controller)
          current_controller.session[:last_edited_w2_id]
        end

        def self.model_for_show_check(current_controller)
          current_controller.current_resource || (last_edited_resource_id(current_controller) ? current_controller.visitor_record.w2s_including_incomplete.find { |w2| w2.id == last_edited_resource_id(current_controller) } : nil)
        end

        def current_resource
          @w2 ||= self.class.current_resource_from_params(current_intake, params)
          raise ActiveRecord::RecordNotFound unless @w2
          @w2
        end

        private

        def initialized_edit_form
          form_class.from_w2(current_resource)
        end

        def initialized_update_form
          form_class.new(current_resource, form_params)
        end

        def remember_last_edited_w2_id
          session[:last_edited_w2_id] = @w2&.id
        end

        def illustration_path
          "documents.svg"
        end
      end
    end
  end
end
