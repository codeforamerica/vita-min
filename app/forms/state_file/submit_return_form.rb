module StateFile
  class SubmitReturnForm < QuestionsForm
    def save
      # make federal return
      # transmit and poll for acks
      # once accepted, build and submit state return

      state_efile_submission = EfileSubmission.create!(
        data_source: @intake,
      )
      state_efile_submission.transition_to(:preparing)

      # submission_bundle = SubmissionBundle.new(
      #   TemporaryNonsense::FakeSubmission.sample_submission(
      #     bundle_class: SubmissionBuilder::Ty2022::States::Ny::IndividualReturn
      #   )
      # )
      # built_bundle = submission_bundle.build
      # puts "ERRORS========================================================="
      # puts built_bundle.errors
      # puts "==============================================================="
    end
  end
end