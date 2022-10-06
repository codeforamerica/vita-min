module Ctc
  module Questions
    class ConfirmW2sController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake, current_controller)
        return unless current_controller.open_for_eitc_intake?

        benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)
        benefits_eligibility.claiming_and_qualified_for_eitc_pre_w2s?
      end

      def self.i18n_base_path
        "views.ctc.questions.w2s"
      end

      def edit
        render 'ctc/questions/w2s/edit'
      end

      def destroy
        current_intake.w2s_including_incomplete.find(params[:id]).destroy!
        redirect_to Ctc::Questions::ConfirmW2sController.to_path_helper
      end

      def form_name
        "ctc_w2s_form"
      end

      def self.form_class
        W2sForm
      end

      def next_path
        if current_intake.had_w2s_yes?
          Ctc::Questions::W2s::EmployeeInfoController.to_path_helper(id: current_intake.new_record_token)
        elsif current_intake.had_w2s_no?
          form_navigation.next(Ctc::Questions::ConfirmW2sController).to_path_helper
        end
      end

      private

      def illustration_path; end
    end
  end
end
