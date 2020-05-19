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
require 'rails_helper'

RSpec.describe SourceParameter, type: :model do
  it { should validate_presence_of(:vita_partner_id) }
  it { should validate_presence_of(:code) }
end
