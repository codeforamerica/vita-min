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
require 'rails_helper'

RSpec.describe VitaPartner, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
