class ChangeIndicatorsToSnapshotOnFraudScore < ActiveRecord::Migration[6.1]
  def change
    rename_column :fraud_scores, :indicators, :snapshot
  end
end
