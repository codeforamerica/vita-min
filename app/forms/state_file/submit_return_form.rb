module StateFile
  class SubmitReturnForm < QuestionsForm
    def save
      efile_submission = EfileSubmission.create!(
        data_source: @intake,
      )
      if Rails.env.development? || Rails.env.test?
        efile_submission.transition_to(:preparing)
      end
    end
  end
end
