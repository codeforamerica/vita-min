# == Schema Information
#
# Table name: state_file_id1099_r_followups
#
#  id                           :bigint           not null, primary key
#  civil_service_account_number :integer          default("unfilled"), not null
#  eligible_income_source       :integer          default("unfilled"), not null
#  firefighter_frf              :integer          default("unfilled"), not null
#  firefighter_persi            :integer          default("unfilled"), not null
#  income_source                :integer          default("unfilled"), not null
#  police_persi                 :integer          default("unfilled"), not null
#  police_retirement_fund       :integer          default("unfilled"), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
FactoryBot.define do
  factory :state_file_id1099_r_followup do
    
  end
end
