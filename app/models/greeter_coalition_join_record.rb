# == Schema Information
#
# Table name: greeter_coalition_join_records
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  coalition_id    :bigint           not null
#  greeter_role_id :bigint           not null
#
# Indexes
#
#  index_greeter_coalition_join_records_on_coalition_id     (coalition_id)
#  index_greeter_coalition_join_records_on_greeter_role_id  (greeter_role_id)
#
# Foreign Keys
#
#  fk_rails_...  (coalition_id => coalitions.id)
#  fk_rails_...  (greeter_role_id => greeter_roles.id)
#
# TODO: delete
class GreeterCoalitionJoinRecord < ApplicationRecord
  # This model exists solely to support GreeterRole.
  belongs_to :greeter_role
  belongs_to :coalition
end
