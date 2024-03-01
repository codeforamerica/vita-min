# == Schema Information
#
# Table name: state_file_w2s
#
#  id                       :bigint           not null, primary key
#  employer_state_id_num    :string
#  local_income_tax_amt     :decimal(12, 2)
#  local_wages_and_tips_amt :decimal(12, 2)
#  locality_nm              :string
#  state_file_intake_type   :string
#  state_income_tax_amt     :decimal(12, 2)
#  state_wages_amt          :decimal(12, 2)
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

  def self.from_df_w2(df_w2)
    attributes = {}
    DirectFileData::DfW2::SELECTORS.keys.each do |selector|
      column_name = selector.to_s.underscore
      if columns_hash[column_name].present?
        attributes[column_name] = df_w2.send(selector.to_sym)
      end
    end
    StateFileW2.new(attributes)
  end

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
