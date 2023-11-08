# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                        :bigint           not null, primary key
#  armed_forces_member       :integer          default("unfilled"), not null
#  armed_forces_wages        :integer
#  bank_account_number       :string
#  bank_account_type         :integer
#  bank_routing_number       :string
#  charitable_cash           :integer          default(0)
#  charitable_contributions  :integer          default("unfilled"), not null
#  charitable_noncash        :integer          default(0)
#  claimed_as_dep            :integer          default("unfilled")
#  contact_preference        :integer          default("unfilled"), not null
#  current_step              :string
#  email_address             :citext
#  email_address_verified_at :datetime
#  has_prior_last_names      :integer          default("unfilled"), not null
#  phone_number              :string
#  phone_number_verified_at  :datetime
#  primary_first_name        :string
#  primary_last_name         :string
#  primary_middle_initial    :string
#  prior_last_names          :string
#  raw_direct_file_data      :text
#  referrer                  :string
#  source                    :string
#  spouse_first_name         :string
#  spouse_last_name          :string
#  spouse_middle_initial     :string
#  tribal_member             :integer          default("unfilled"), not null
#  tribal_wages              :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visitor_id                :string
#
FactoryBot.define do
  factory :state_file_az_intake do
    raw_direct_file_data { File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml')) }
    claimed_as_dep { 'no' }
    primary_first_name { "Ariz" }
    primary_last_name { "Onian" }
  end
end
