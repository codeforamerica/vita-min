module Ctc
  module Questions
    class ConfirmW2sController < W2sController
      skip_before_action :track_w2s_list_first_visit

      def self.i18n_base_path
        "views.ctc.questions.w2s"
      end

      def edit
        super
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
    end
  end
end
