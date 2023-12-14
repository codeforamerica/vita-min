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
#  non_expiring        :boolean          default(FALSE)
#  state               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class StateId < ApplicationRecord
  has_one :intake_as_primary, class_name: "StateFileNyIntake", foreign_key: "primary_state_id"
  has_one :intake_as_spouse, class_name: "StateFileNyIntake", foreign_key: "spouse_state_id"
  enum id_type: { unfilled: 0, driver_license: 1, dmv_bmv: 2, no_id: 3 }, _prefix: :id_type

  before_save do
    if id_type_changed?(to: "no_id") || id_type_changed?(to: "unfilled")
      self.expiration_date = nil
      self.first_three_doc_num = nil
      self.id_number = nil
      self.issue_date = nil
      self.state = nil
    end
    if self.non_expiring?
      self.expiration_date = nil
    end
  end

end
