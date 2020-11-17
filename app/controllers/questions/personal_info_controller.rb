module Questions
  class PersonalInfoController < QuestionsController
    def illustration_path; end

    def tracking_data
      {}
    end

    def after_update_success
      is_in_progress = current_intake.client.tax_returns.where("status >= ?", TaxReturn.statuses["intake_in_progress"]).exists?
      current_intake.assign_vita_partner! unless is_in_progress
    end
  end
end
