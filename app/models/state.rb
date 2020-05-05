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
class State < ApplicationRecord
  has_and_belongs_to_many :vita_partners, foreign_key: :state_abbreviation
end
