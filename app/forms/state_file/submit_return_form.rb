module StateFile
  class SubmitReturnForm < QuestionsForm
    def save
      # submission = TemporaryNonsense::FakeSubmission.sample_submission(
      #   bundle_class: SubmissionBuilder::Ty2022::States::Ny::IndividualReturn
      # )
      #
      # BuildSubmissionBundleJob.perform_later(submission.id)

      # make federal return
      # transmit and poll for acks
      # once accepted, build and submit state return

      state_file_ny_intake = StateFileNyIntake.create!
      state_efile_submission = StateEfileSubmission.create!(
        irs_submission_id: '4414662023103zvnoell',
        intake: state_file_ny_intake,
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