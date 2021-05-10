# == Schema Information
#
# Table name: bulk_client_organization_updates
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  tax_return_selection_id :bigint
#  vita_partner_id         :bigint           not null
#
# Indexes
#
#  index_bcou_on_tax_return_selection_id                      (tax_return_selection_id)
#  index_bulk_client_organization_updates_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (tax_return_selection_id => tax_return_selections.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class BulkClientOrganizationUpdate < ApplicationRecord
  has_one :user_notification, as: :notifiable
  belongs_to :tax_return_selection
  belongs_to :vita_partner
end
