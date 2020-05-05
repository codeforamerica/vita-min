# == Schema Information
#
# Table name: vita_partners
#
#  id                      :bigint           not null, primary key
#  display_name            :string
#  logo_path               :string
#  name                    :string           not null
#  source_parameter        :string
#  zendesk_instance_domain :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  zendesk_group_id        :string           not null
#
class VitaPartner < ApplicationRecord
  has_many :intakes
  has_and_belongs_to_many :states, association_foreign_key: :state_abbreviation
  has_many :source_codes
end
