class RenameWeeklyCapacityLimitToCapacityLimit < ActiveRecord::Migration[6.0]
  def change
    rename_column :vita_partners, :weekly_capacity_limit, :capacity_limit
  end
end
