class ClaimRegardlessToAnywaysOnDependent < ActiveRecord::Migration[6.0]
  def change
    rename_column :dependents, :claim_regardless, :claim_anyway
  end
end
