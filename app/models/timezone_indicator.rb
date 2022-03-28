# == Schema Information
#
# Table name: timezone_indicators
#
#  id           :bigint           not null, primary key
#  activated_at :datetime
#  name         :string
#  override     :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class TimezoneIndicator < ApplicationRecord
  validates_uniqueness_of :name
  default_scope { where.not(activated_at: nil) }

  def self.safelist
    all.pluck(:name).push(nil)
  end
end
