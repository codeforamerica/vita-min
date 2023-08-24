# == Schema Information
#
# Table name: experiments
#
#  id         :bigint           not null, primary key
#  enabled    :boolean          default(FALSE)
#  key        :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_experiments_on_key  (key) UNIQUE
#
class Experiment < ApplicationRecord
  has_many :experiment_participants
  has_many :experiment_vita_partners
  has_many :vita_partners, through: :experiment_vita_partners

  def treatment_weights
    ExperimentService::CONFIG[key][:treatment_weights]
  end
end
