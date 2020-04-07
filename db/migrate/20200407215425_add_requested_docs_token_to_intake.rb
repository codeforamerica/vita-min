class AddRequestedDocsTokenToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :requested_docs_token, :string
    add_column :intakes, :requested_docs_token_created_at, :datetime
  end
end
