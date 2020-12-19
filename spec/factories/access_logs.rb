# == Schema Information
#
# Table name: access_logs
#
#  id         :bigint           not null, primary key
#  ip_address :inet
#  user_agent :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_access_logs_on_client_id  (client_id)
#  index_access_logs_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :access_log do
    client
    user
    ip_address { "1.1.1.1" }
    user_agent { "CERN-NextStep-WorldWideWeb.app/1.1 libwww/2.07" }
  end
end
