# == Schema Information
#
# Table name: organization_capacities
#
#  active_client_count :bigint
#  capacity_limit      :integer
#  name                :string
#  vita_partner_id     :bigint           primary key
#
class VitaPartnerCapacity < ApplicationRecord
  belongs_to :vita_partner, foreign_key: "vita_partner_id"
  self.primary_key = :vita_partner_id # vita partner id
  scope :with_capacity, lambda {
    where(arel_table[:capacity_limit].eq(nil)).or(
      where.not(arel_table[:capacity_limit].eq(0))
        .where(arel_table[:active_client_count].lt(arel_table[:capacity_limit]))
    )
  }
  # Prevents us from calling #save on a view, which would fail anyway.
  def readonly?
    true
  end
end
