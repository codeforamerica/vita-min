module Questions
  class SsnItinController < QuestionsController
    include AnonymousIntakeConcern

    def self.show?(intake)
      intake.itin_applicant? ? false : true
    end

    def illustration_path; end

    def tracking_data
      {}
    end
  end
end
