module Stimulus
  class FilingMightHelpController < StimulusController
    layout "question"

    def update
      @form = form_class.new(current_stimulus_triage, form_params)
      if @form.valid?
        @form.save
        after_update_success
        redirect_based_on_response
      else
        track_validation_error
        render :edit
      end
    end

    def redirect_based_on_response
      if current_stimulus_triage.chose_to_file_yes?
        redirect_to backtaxes_questions_path
      else
        session.delete(:stimulus_triage_id)
        redirect_to stimulus_path
      end
    end

    class << self
      def show?(triage)
        triage.need_to_file_no? || triage.filed_prior_years_no?
      end
    end
  end
end
