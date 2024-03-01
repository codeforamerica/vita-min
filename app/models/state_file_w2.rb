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

  validates :employer_state_id_num, account_number: true
  validates :state_wages_amt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :state_income_tax_amt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :local_wages_and_tips_amt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :local_income_tax_amt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :locality_nm, presence: true, if: -> { local_wages_and_tips_amt.present? }
  validates :local_wages_and_tips_amt, presence: true, if: -> { local_income_tax_amt.present? }
  validates :state_wages_amt, presence: true, if: -> { state_income_tax_amt.present? }
  validates :employer_state_id_num, presence: true, if: -> { employer_state_id_num.present? }

  def to_df_w2(df_w2)
    DirectFileData::DfW2::SELECTORS.keys.each do |selector|
      column_name = selector.to_s.underscore
      if columns_hash[column_name].present?
        value = send(column_name.to_sym)
        attributes[column_name] = df_w2.send("#{selector}=".to_sym, value)
      end
    end
  end
end
