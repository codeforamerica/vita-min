# == Schema Information
#
# Table name: state_ids
#
#  id                  :bigint           not null, primary key
#  expiration_date     :date
#  first_three_doc_num :string
#  id_number           :string
#  id_type             :integer          default("unfilled"), not null
#  issue_date          :date
#  state               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class StateId < ApplicationRecord
  has_one :intake_as_primary, class_name: "StateFileNyIntake", foreign_key: "primary_state_id"
  has_one :intake_as_spouse, class_name: "StateFileNyIntake", foreign_key: "spouse_state_id"
  enum id_type: { unfilled: 0, driver_license: 1, dmv_bmv: 2, no_id: 3 }, _prefix: :id_type
end
