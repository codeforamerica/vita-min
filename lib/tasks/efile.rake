namespace :efile do
  desc "Tasks for e-filing"
  task poll_and_get_acknowledgments: :environment do
    Efile::PollForAcknowledgmentsService.run
  end

  # rake efile:retry_failed_submissions -- "example@codeforamerica.org"
  task retry_failed_submissions: :environment do
    user = User.find_by(email: ARGV.last)

    puts("Printing 1 dot per EfileSubmission:")
    EfileSubmission.in_state(:failed).find_each(batch_size: 100) do |submission|
      submission.transition_to!(:resubmitted, { initiated_by_id: user.id })
      print(".")
    end

    print("\n")
    puts("Done.")
    exit
  end
end