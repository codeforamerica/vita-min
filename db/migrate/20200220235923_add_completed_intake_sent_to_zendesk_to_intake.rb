class AddCompletedIntakeSentToZendeskToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :completed_intake_sent_to_zendesk, :boolean
  end
end
