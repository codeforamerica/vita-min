# == Schema Information
#
# Table name: archived_w2_state_fields_groups_2022
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
#  archived_w2s_2022_id           :bigint           not null
#
# Indexes
#
#  index_arc_w2_sfg_2022_on_arc_w2_2022_id  (archived_w2s_2022_id)
#
# Foreign Keys
#
#  fk_rails_...  (archived_w2s_2022_id => archived_w2s_2022.id)
#
class Archived::W2StateFieldsGroup2022 < ApplicationRecord
  self.table_name = 'archived_w2_state_fields_groups_2022'

  belongs_to :w2, foreign_key: 'archived_w2s_2022_id', class_name: 'Archived::W22022'
end
