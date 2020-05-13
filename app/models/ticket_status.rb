# == Schema Information
#
# Table name: ticket_statuses
#
#  id              :bigint           not null, primary key
#  intake_status   :string           not null
#  return_status   :string           not null
#  verified_change :boolean          default(TRUE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  intake_id       :bigint
#  ticket_id       :integer
#
# Indexes
#
#  index_ticket_statuses_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#
class TicketStatus < ApplicationRecord
  belongs_to :intake

  def status_changed?(intake_status:, return_status:)
    self.intake_status != intake_status || self.return_status != return_status
  end

  def mixpanel_data
    {
      verified_change: verified_change,
      ticket_id: ticket_id,
      intake_status: intake_status,
      return_status: return_status,
      created_at: created_at.utc.iso8601,
    }
  end
end
