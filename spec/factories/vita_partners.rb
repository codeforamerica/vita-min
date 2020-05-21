# == Schema Information
#
# Table name: vita_partners
#
#  id                      :bigint           not null, primary key
#  accepts_overflow        :boolean          default(FALSE)
#  display_name            :string
#  logo_path               :string
#  name                    :string           not null
#  source_parameter        :string
#  zendesk_instance_domain :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  zendesk_group_id        :string           not null
#
FactoryBot.define do
  factory :vita_partner do
    name { "Vita Partner Name" }
    zendesk_instance_domain { EitcZendeskInstance::DOMAIN }
    zendesk_group_id { "group_id" }
  end
end
