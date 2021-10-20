# delete this later maybe - it should never happen again, inshallah

class RunAfterTransitionTasksOnRejectedReturnsJob < ApplicationJob
  def perform(limit)
    # get rejected submissions where tax return status doesn't match
    rejected_submissions = EfileSubmission
      .in_state(:rejected)
      .includes(:tax_return).where(tax_returns: {status: "file_efiled"})

    rejected_submissions = rejected_submissions.limit(limit) if limit.present?

    rejected_submissions.find_each(batch_size: 100) do |submission|
      AfterTransitionTasksForRejectedReturnJob.perform_later(submission)
    end
  end
end