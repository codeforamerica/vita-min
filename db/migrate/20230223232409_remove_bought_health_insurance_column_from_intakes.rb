class RemoveBoughtHealthInsuranceColumnFromIntakes < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :intakes, :bought_health_insurance }
  end
end
