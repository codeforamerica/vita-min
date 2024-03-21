namespace :survey_notifications do
  desc 'Send survey notifications to all accepted returns prior to our shipping this feature'
  task 'send' => :environment do
    include StateFile::SurveyLinksConcern
    BATCH_SIZE = 10
    accepted_submissions = EfileSubmission.joins(:efile_submission_transitions)
                                          .where("efile_submission_transitions.to_state = 'accepted'")
                                          .where.not("message_tracker #> '{messages.state_file.survey_notification}' IS NOT NULL")

    binding.pry
    accepted_submissions.each_slice(BATCH_SIZE) do |batch|
      batch.each do |submission|
        puts "Sending survey notification to #{submission.id}"
        StateFile::MessagingService.new(
          intake: submission.data_source,
          submission: submission,
          message: StateFile::AutomatedMessage::SurveyNotification,
          body_args: { survey_link: survey_link(submission.data_source) }
        ).send_message
      end
    end
  end
end
