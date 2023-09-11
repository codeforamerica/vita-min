class SetNotNullForNyIntakeFields < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_column_null :state_file_ny_intakes, :filing_status, false
      change_column_null :state_file_ny_intakes, :claimed_as_dep, false

      change_column_default :state_file_ny_intakes, :nyc_resident_e, 0
      change_column_default :state_file_ny_intakes, :refund_choice, 0
      change_column_default :state_file_ny_intakes, :account_type, 0
      change_column_default :state_file_ny_intakes, :amount_owed_pay_electronically, 0
      change_column_default :state_file_ny_intakes, :occupied_residence, 0
      change_column_default :state_file_ny_intakes, :property_over_limit, 0
      change_column_default :state_file_ny_intakes, :public_housing, 0
      change_column_default :state_file_ny_intakes, :nursing_home, 0
      change_column_default :state_file_ny_intakes, :household_rent_own, 0

      change_column_null :state_file_ny_intakes, :nyc_resident_e, false
      change_column_null :state_file_ny_intakes, :refund_choice, false
      change_column_null :state_file_ny_intakes, :account_type, false
      change_column_null :state_file_ny_intakes, :amount_owed_pay_electronically, false
      change_column_null :state_file_ny_intakes, :occupied_residence, false
      change_column_null :state_file_ny_intakes, :property_over_limit, false
      change_column_null :state_file_ny_intakes, :public_housing, false
      change_column_null :state_file_ny_intakes, :nursing_home, false
      change_column_null :state_file_ny_intakes, :household_rent_own, false
    end
  end
end
