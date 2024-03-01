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
  validate :validate_w2

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

  def validate_w2
    #TODO: Proper messages
    if state_wages_amt == 0
      errors.add(:state_wages_amt, "Need a proper message here")
    end
    if state_file_intake.nyc_residency_full_year?
      errors.add(:local_wages_and_tips_amt, "Need a proper message here") if local_wages_and_tips_amt == 0 || locality_nm.blank?
    end
    if locality_nm.blank?
      errors.add(:local_wages_and_tips_amt, "Need a proper message here") if local_wages_and_tips_amt != 0 || local_income_tax_amt != 0
    end
    errors.add(:local_income_tax_amt, "Need a proper message here") if local_income_tax_amt != 0 && local_wages_and_tips_amt == 0
    errors.add(:state_income_tax_amt, "Need a proper message here") if state_income_tax_amt != 0 && state_wages_amt == 0
    errors.add(:state_wages_amt, "Need a proper message here") if state_wages_amt != 0 && employer_state_id_num.blank?
    errors.add(:locality_nm, "Need a proper message here") if locality_nm.present? && !StateFileNyIntake::LOCALITIES.include?(locality_nm)
  end
end
