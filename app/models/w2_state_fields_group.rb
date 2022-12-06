# == Schema Information
#
# Table name: w2_state_fields_groups
#
#  id                             :bigint           not null, primary key
#  box15_employer_state_id_number :string
#  box15_state                    :string
#  box16_state_wages              :decimal(12, 2)
#  box17_state_income_tax         :decimal(12, 2)
#  box18_local_wages              :decimal(12, 2)
#  box19_local_income_tax         :decimal(12, 2)
#  box20_locality_name            :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  w2_id                          :bigint           not null
#
# Indexes
#
#  index_w2_state_fields_groups_on_w2_id  (w2_id)
#
# Foreign Keys
#
#  fk_rails_...  (w2_id => archived_w2s_2022.id)
#
class W2StateFieldsGroup < ApplicationRecord
  belongs_to :w2
end
