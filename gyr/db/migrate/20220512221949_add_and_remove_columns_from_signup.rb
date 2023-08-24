class AddAndRemoveColumnsFromSignup < ActiveRecord::Migration[7.0]
  def change
    add_column :signups, :ctc_2022_open_message_sent_at, :timestamp
    safety_assured { remove_column :signups, :sent_followup, :boolean }
  end
end
