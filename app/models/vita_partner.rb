# == Schema Information
#
# Table name: vita_partners
#
#  id                      :bigint           not null, primary key
#  logo_url                :string
#  name                    :string           not null
#  zendesk_instance_domain :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  zendesk_group_id        :string           not null
#
class VitaPartner < ApplicationRecord
  has_many :intakes
end
