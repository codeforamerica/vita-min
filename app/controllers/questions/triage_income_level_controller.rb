module Questions
  class TriageIncomeLevelController < TriageController
    layout "intake"

    class MinimumForm < Form
    end

    def edit
      @form = MinimumForm.new
    end

    def update
      if update_params[:income_level] == "hh_over_73000"
        redirect_to maybe_ineligible_path
      elsif update_params[:income_level] == "hh_66000_to_73000"
        redirect_to diy_file_yourself_path
      else
        redirect_to next_path
      end
    end

    private

    def illustration_path; end

    def update_params
      params.require(:questions_triage_income_level_controller_minimum_form).permit(:income_level)
    end
  end
end
