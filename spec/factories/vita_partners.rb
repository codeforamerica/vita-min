# == Schema Information
#
# Table name: vita_partners
#
#  id                      :bigint           not null, primary key
#  accepts_overflow        :boolean          default(FALSE)
#  archived                :boolean          default(FALSE)
#  display_name            :string
#  logo_path               :string
#  name                    :string           not null
#  source_parameter        :string
#  weekly_capacity_limit   :integer
#  zendesk_instance_domain :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  parent_organization_id  :bigint
#  zendesk_group_id        :string           not null
#
# Indexes
#
#  index_vita_partners_on_parent_organization_id  (parent_organization_id)
#
FactoryBot.define do
  factory :vita_partner do
    sequence(:name) { |n| "Partner #{n}"}
    sequence(:display_name) { |n| "Partner #{n}"}
    zendesk_instance_domain { EitcZendeskInstance::DOMAIN }
    sequence(:zendesk_group_id) { |n| n.to_s }
  end
end
