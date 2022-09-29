# == Schema Information
#
# Table name: ds_click_histories
#
#  id                  :bigint           not null, primary key
#  w2_logout_add_later :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  client_id           :bigint           not null
#
# Indexes
#
#  index_ds_click_histories_on_client_id  (client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
FactoryBot.define do
  factory :data_science_click_history, class: DataScience::ClickHistory do
  end
end
