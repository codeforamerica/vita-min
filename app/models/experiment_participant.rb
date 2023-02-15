# == Schema Information
#
# Table name: experiment_participants
#
#  id            :bigint           not null, primary key
#  record_type   :string           not null
#  treatment     :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  experiment_id :string
#  record_id     :bigint           not null
#
# Indexes
#
#  index_experiment_participants_on_record  (record_type,record_id)
#
class ExperimentParticipant < ApplicationRecord
  belongs_to :record, polymorphic: true
end
