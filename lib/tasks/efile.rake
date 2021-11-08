namespace :efile do
  desc "Tasks for e-filing"
  task poll_and_get_acknowledgments: :environment do
    Efile::PollForAcknowledgmentsService.run
  end

  # rake efile:retry_failed_submissions -- "example@codeforamerica.org" 1000
  task retry_failed_submissions: :environment do
    puts("Start: Found #{EfileSubmission.in_state(:failed).count} failed submissions")

    user = User.find_by(email: ARGV[-2])
    limit = ARGV[-1].to_i

    puts("#{user.email} retrying up to #{limit} failed efile submissions")

    puts("Printing 1 dot per EfileSubmission:")
    EfileSubmission.in_state(:failed).limit(limit) do |submission|
      submission.transition_to!(:resubmitted, { initiated_by_id: user.id })
      print(".")
    end

    print("\n")
    puts("End: Found #{EfileSubmission.in_state(:failed).count} failed submissions")
    exit
  end
end
