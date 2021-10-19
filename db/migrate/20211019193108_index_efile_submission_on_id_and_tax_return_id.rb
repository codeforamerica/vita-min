class IndexEfileSubmissionOnIdAndTaxReturnId < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :efile_submissions, [:tax_return_id, :id], order: {id: :desc}, algorithm: :concurrently
  end
end
