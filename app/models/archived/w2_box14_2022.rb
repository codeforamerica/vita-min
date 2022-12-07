# == Schema Information
#
# Table name: archived_w2_box14s_2022
#
#  id                   :bigint           not null, primary key
#  other_amount         :decimal(12, 2)
#  other_description    :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  archived_w2s_2022_id :bigint           not null
#
# Indexes
#
#  index_archived_w2_box14s_2022_on_archived_w2s_2022_id  (archived_w2s_2022_id)
#
# Foreign Keys
#
#  fk_rails_...  (archived_w2s_2022_id => archived_w2s_2022.id)
#
class Archived::W2Box142022 < ApplicationRecord
  self.table_name = 'archived_w2_box14s_2022'

  belongs_to :w2, foreign_key: 'archived_w2s_2022_id', class_name: 'Archived::W22022'
end
