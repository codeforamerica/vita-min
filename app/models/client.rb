# == Schema Information
#
# Table name: clients
#
#  id               :bigint           not null, primary key
#  email_address    :string
#  phone_number     :string
#  preferred_name   :string
#  sms_phone_number :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Client < ApplicationRecord
  has_many :intakes
  has_many :outgoing_text_messages
  has_many :outgoing_emails
  has_many :incoming_text_messages
  has_many :incoming_emails
  has_many :group_assignments
  has_many :assigned_groups, through: :group_assignments, source: :group

  def self.create_from_intake(intake)
    create(
      preferred_name: intake.preferred_name,
      email_address: intake.email_address,
      phone_number: intake.phone_number,
      sms_phone_number: intake.sms_phone_number,
    )
  end

  def accessible_to?(user)
    group_assignments.where(id: user.groups).exists?
  end

  def users_with_access
    User.joins(:groups).where(groups: {id: assigned_groups})
  end
end
