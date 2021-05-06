class RemoveRequestedDocumentsLaterFieldsFromIntake < ActiveRecord::Migration[6.0]
  def change
    remove_column :intakes, :requested_docs_token, :string
    remove_column :intakes, :requested_docs_token_created_at, :datetime
  end
end
