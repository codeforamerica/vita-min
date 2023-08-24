class AddCompletedAtToDocumentRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :documents_requests, :completed_at, :datetime
  end
end
