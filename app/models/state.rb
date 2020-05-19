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
  has_and_belongs_to_many :vita_partners, foreign_key: :state_abbreviation

  validates_presence_of :name
  validates_presence_of :abbreviation
end
