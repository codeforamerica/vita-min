class AddBetaEmailSentAtToCtcSignup < ActiveRecord::Migration[6.0]
  def change
    add_column :ctc_signups, :beta_email_sent_at, :datetime
  end
end
