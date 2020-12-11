# == Schema Information
#
# Table name: states
#
#  abbreviation :string           not null, primary key
#  name         :string
#
# Indexes
#
#  index_states_on_name  (name)
#
class State < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :abbreviation
end
