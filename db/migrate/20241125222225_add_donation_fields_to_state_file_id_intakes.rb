class AddDonationFieldsToStateFileIdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id_intakes, :nongame_wildlife_fund_donation, :decimal, precision: 12, scale: 2
    add_column :state_file_id_intakes, :childrens_trust_fund_donation, :decimal, precision: 12, scale: 2
    add_column :state_file_id_intakes, :special_olympics_donation, :decimal, precision: 12, scale: 2
    add_column :state_file_id_intakes, :guard_reserve_family_donation, :decimal, precision: 12, scale: 2
    add_column :state_file_id_intakes, :american_red_cross_fund_donation, :decimal, precision: 12, scale: 2
    add_column :state_file_id_intakes, :veterans_support_fund_donation, :decimal, precision: 12, scale: 2
    add_column :state_file_id_intakes, :food_bank_fund_donation, :decimal, precision: 12, scale: 2
    add_column :state_file_id_intakes, :opportunity_scholarship_program_donation, :decimal, precision: 12, scale: 2
  end
end
