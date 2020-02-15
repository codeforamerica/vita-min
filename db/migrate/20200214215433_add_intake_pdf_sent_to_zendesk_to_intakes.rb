class AddIntakePdfSentToZendeskToIntakes < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :intake_pdf_sent_to_zendesk, :boolean, default: false, null: false
  end
end
