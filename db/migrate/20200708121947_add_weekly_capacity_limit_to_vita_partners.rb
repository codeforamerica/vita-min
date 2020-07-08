class AddWeeklyCapacityLimitToVitaPartners < ActiveRecord::Migration[6.0]
  def change
    add_column :vita_partners, :weekly_capacity_limit, :integer
  end
end
