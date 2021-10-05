# == Schema Information
#
# Table name: recaptcha_scores
#
#  id         :bigint           not null, primary key
#  action     :string           not null
#  score      :decimal(, )      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#
# Indexes
#
#  index_recaptcha_scores_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
require 'rails_helper'

RSpec.describe RecaptchaScore, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
