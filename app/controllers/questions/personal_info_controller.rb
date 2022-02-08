module Questions
  class PersonalInfoController < QuestionsController
    include AnonymousIntakeConcern

    def edit
      @show_ssn_field = current_intake&.triage&.id_type_need_help? ? false : true
      super
    end

    def illustration_path; end

    def tracking_data
      {}
    end
  end
end
