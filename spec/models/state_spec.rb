# == Schema Information
#
# Table name: states
#
#  abbreviation :string           not null, primary key
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_states_on_name  (name)
#
require 'rails_helper'

RSpec.describe State, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
