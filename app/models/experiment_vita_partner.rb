# == Schema Information
#
# Table name: experiment_vita_partners
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  experiment_id   :bigint           not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_experiment_vita_partners_on_experiment_id    (experiment_id)
#  index_experiment_vita_partners_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (experiment_id => experiments.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class ExperimentVitaPartner < ApplicationRecord
  belongs_to :experiment
  belongs_to :vita_partner
end
