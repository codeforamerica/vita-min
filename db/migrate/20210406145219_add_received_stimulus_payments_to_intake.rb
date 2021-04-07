class AddReceivedStimulusPaymentsToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :received_stimulus_payment, :integer, default: 0, null: false
  end
end
