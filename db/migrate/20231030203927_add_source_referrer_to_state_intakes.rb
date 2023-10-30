class AddSourceReferrerToStateIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :source, :string
    add_column :state_file_az_intakes, :referrer, :string
    add_column :state_file_ny_intakes, :source, :string
    add_column :state_file_ny_intakes, :referrer, :string
  end
end
