# == Schema Information
#
# Table name: vita_partners
#
#  id                      :bigint           not null, primary key
#  display_name            :string
#  drop_off_code           :string
#  logo_url                :string
#  name                    :string           not null
#  referral_code           :string
#  zendesk_instance_domain :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  zendesk_group_id        :string           not null
#
FactoryBot.define do
  factory :vita_partner do
    name { "Vita Partner Name" }
    zendesk_instance_domain { "EitcZendeskInstance" }
    zendesk_group_id { "group_id" }
  end
end
