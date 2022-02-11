module Questions
  class PersonalInfoController < QuestionsController
    include AnonymousIntakeConcern

    def edit
      @hide_ssn_field = current_intake.itin_applicant?
      super
    end

    def illustration_path; end

    def tracking_data
      {}
    end
  end
end
