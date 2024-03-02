# == Schema Information
#
# Table name: state_file_w2s
#
#  id                       :bigint           not null, primary key
#  employer_state_id_num    :string
#  local_income_tax_amt     :integer
#  local_wages_and_tips_amt :integer
#  locality_nm              :string
#  state_file_intake_type   :string
#  state_income_tax_amt     :integer
#  state_wages_amt          :integer
#  w2_index                 :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  state_file_intake_id     :bigint
#
# Indexes
#
#  index_state_file_w2s_on_state_file_intake  (state_file_intake_type,state_file_intake_id)
#
class StateFileW2 < ApplicationRecord
  belongs_to :state_file_intake, polymorphic: true

  validates :w2_index, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :employer_state_id_num, format: { with: /\A(\d{0,17})\z/ }
  validates :state_wages_amt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :state_income_tax_amt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :local_wages_and_tips_amt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :local_income_tax_amt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :locality_nm, presence: true, if: -> { local_wages_and_tips_amt.present? && local_wages_and_tips_amt.positive? }
  validates :local_wages_and_tips_amt, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, if: -> { local_income_tax_amt.present? && local_income_tax_amt.positive? }
  validates :state_wages_amt, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, if: -> { state_income_tax_amt.present? && state_income_tax_amt.positive? }
  validates :employer_state_id_num, presence: true, if: -> { state_wages_amt.present? && state_wages_amt.positive? }

end
