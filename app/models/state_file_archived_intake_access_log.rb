# == Schema Information
#
# Table name: state_file_archived_intake_access_logs
#
#  id                             :bigint           not null, primary key
#  details                        :jsonb
#  event_type                     :integer
#  ip_address                     :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  state_file_archived_intakes_id :bigint
#
# Indexes
#
#  idx_on_state_file_archived_intakes_id_e878049c06  (state_file_archived_intakes_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_file_archived_intakes_id => state_file_archived_intakes.id)
#
class StateFileArchivedIntakeAccessLog < ApplicationRecord
  belongs_to :state_file_archived_intake, foreign_key: :state_file_archived_intakes_id, optional: true
  enum event_type: {
    correct_email_address: 0, # redundant
    incorrect_email_address: 0, # redundant
    incorrect_email_address: 0,
    correct_verification_code: 1,
    incorrect_verification_code: 2,
    issued_ssn_challenge: 3, # redundant
    correct_ssn_challenge: 4,
    incorrect_ssn_challenge: 5,
    client_lockout_begin: 6,
    client_lockout_end: 7,
    issued_mailing_address_challenge: 8, # redundant
    correct_mailing_address: 9,
    incorrect_mailing_address: 10,
    issued_pdf_download_link: 11,
    client_pdf_download_click: 12,
    pdf_download_link_expired: 13,
  }, _prefix: :event_type
end
