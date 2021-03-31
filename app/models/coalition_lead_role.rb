# == Schema Information
#
# Table name: coalition_lead_roles
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  coalition_id :bigint           not null
#
# Indexes
#
#  index_coalition_lead_roles_on_coalition_id  (coalition_id)
#
# Foreign Keys
#
#  fk_rails_...  (coalition_id => coalitions.id)
#
class CoalitionLeadRole < ApplicationRecord
  TYPE = "CoalitionLeadRole"

  belongs_to :coalition

  def served_entity
    coalition
  end
end
