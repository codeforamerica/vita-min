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
      #check if they are return clients
    end
  end
end
