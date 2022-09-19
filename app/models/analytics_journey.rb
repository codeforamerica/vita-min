# == Schema Information
#
# Table name: analytics_journeys
#
#  id                  :bigint           not null, primary key
#  w2_logout_add_later :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  client_id           :bigint           not null
#
# Indexes
#
#  index_analytics_journeys_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
class AnalyticsJourney < ApplicationRecord
  belongs_to :client
end
