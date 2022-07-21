class AddPuertoRicoOpenSentAtToSignup < ActiveRecord::Migration[7.0]
  def change
    add_column :signups, :puerto_rico_open_message_sent_at, :datetime
  end
end
