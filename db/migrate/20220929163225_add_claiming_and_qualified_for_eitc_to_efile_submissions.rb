class AddClaimingAndQualifiedForEitcToEfileSubmissions < ActiveRecord::Migration[7.0]
  def change
    add_column :efile_submissions, :claiming_and_qualified_for_eitc, :boolean
  end
end
