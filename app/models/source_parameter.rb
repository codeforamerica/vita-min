# == Schema Information
#
# Table name: source_parameters
#
#  id              :bigint           not null, primary key
#  code            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_source_parameters_on_code             (code) UNIQUE
#  index_source_parameters_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class SourceParameter < ApplicationRecord
  belongs_to :vita_partner

  validates_presence_of :vita_partner_id
  validates_presence_of :code
  validates_uniqueness_of :code
end
