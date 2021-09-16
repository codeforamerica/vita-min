namespace :tax_return_analytics do
  desc "backfills expected payment data for accepted efiled tax returns"
  task backfill: [:environment] do
    wrong_state = 0
    recorded_payments = 0
    EfileSubmissionTransition.where(most_recent: true, to_state: "accepted").find_each do |transition|
      tax_return = transition.submission.tax_return
      # i do not expect this to happen often, but when we FIRST released, it was possible to
      # change your tax return status back to "not ready" if you re-entered the flow after submitting your return.
      unless tax_return.status == "file_accepted"
        tax_return.update(status: "file_accepted")
        wrong_state += 1
        puts "!!! Updated tax return #{tax_return.id} status to accepted"
      end
      tax_return.record_expected_payments!
      recorded_payments += 1
      puts "--- Recorded expected payments for tax return #{tax_return.id}"
    end
    puts "******************** #{wrong_state} returns are now accepted, #{recorded_payments} have recorded payments"
  end
end