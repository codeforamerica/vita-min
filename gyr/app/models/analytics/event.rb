# == Schema Information
#
# Table name: analytics_events
#
#  id         :bigint           not null, primary key
#  event_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#
# Indexes
#
#  index_analytics_events_on_client_id                 (client_id)
#  index_analytics_events_on_event_type_and_client_id  (event_type,client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
module Analytics
  class Event < ApplicationRecord
    self.table_name = "analytics_events"

    belongs_to :client
  end
end
