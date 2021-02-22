class AddSentFollowupToSignup < ActiveRecord::Migration[6.0]
  def change
    add_column :signups, :sent_followup, :boolean, default: false
  end
end
