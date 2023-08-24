module Questions
  class SsnItinController < QuestionsController
    include AnonymousIntakeConcern

    def self.show?(intake)
      !intake.itin_applicant?
    end

    def illustration_path; end

    def tracking_data
      {}
    end

    def after_update_success
      current_intake.update(matching_previous_year_intake: current_intake.matching_previous_year_intakes&.first)
    end
  end
end
