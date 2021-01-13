# == Schema Information
#
# Table name: tax_returns
#
#  id                  :bigint           not null, primary key
#  certification_level :integer
#  is_hsa              :boolean
#  primary_signed_at   :datetime
#  primary_signed_ip   :inet
#  service_type        :integer          default("online_intake")
#  status              :integer          default("intake_before_consent"), not null
#  year                :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  assigned_user_id    :bigint
#  client_id           :bigint           not null
#
# Indexes
#
#  index_tax_returns_on_assigned_user_id    (assigned_user_id)
#  index_tax_returns_on_client_id           (client_id)
#  index_tax_returns_on_year_and_client_id  (year,client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (assigned_user_id => users.id)
#  fk_rails_...  (client_id => clients.id)
#
class TaxReturn < ApplicationRecord
  belongs_to :client
  belongs_to :assigned_user, class_name: "User", optional: true
  has_many :documents

  enum status: TaxReturnStatus::STATUSES, _prefix: :status
  enum certification_level: { advanced: 1, basic: 2 }
  enum service_type: { online_intake: 0, drop_off: 1 }, _prefix: :service_type
  validates :year, presence: true
  
  ##
  # advance the return to a new status, only if that status more advanced.
  # An earlier or equal status will be ignored.
  #
  # @param [String] new_status: the name of the status to advance to
  #
  def advance_to(new_status)
    update!(status: new_status) if TaxReturn.statuses[status.to_sym] < TaxReturn.statuses[new_status.to_sym]
  end

  def self.filing_years
    [2020, 2019, 2018, 2017]
  end
end
