# == Schema Information
#
# Table name: site_coordinator_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_site_coordinator_roles_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
FactoryBot.define do
  factory :site_coordinator_role do
    sites { [create(:site)] }
  end
end
