namespace :tax_return_analytics do
  desc "backfills expected payment data for accepted efiled tax returns"
  task backfill: [:environment] do
    EfileSubmissionTransition.where(most_recent: true, to_state: "accepted").find_each do |transition|
      tax_return = transition.submission.tax_return
      # i do not expect this to happen often, but when we FIRST released, it was possible to
      # change your tax return status back to "not ready" if you re-entered the flow after submitting your return.
      unless tax_return.status == "file_accepted"
        tax_return.update(status: "file_accepted")
        puts "Updated tax return #{tax_return.id} status to accepted"
      end
      tax_return.record_expected_payments!
    end
  end
end