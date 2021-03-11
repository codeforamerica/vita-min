# == Schema Information
#
# Table name: organization_capacities
#
#  active_client_count :bigint
#  capacity_limit      :integer
#  name                :string
#  vita_partner_id     :bigint           primary key
#
class OrganizationCapacity < ApplicationRecord
  belongs_to :vita_partner
  self.primary_key = :vita_partner_id # vita partner id

  # Prevents us from calling #save on a view, which would fail anyway.
  def readonly?
    true
  end
end
