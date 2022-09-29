class AddClaimedEitcToEfileSubmissions < ActiveRecord::Migration[7.0]
  def change
    add_column :efile_submissions, :claimed_eitc, :boolean
  end
end
