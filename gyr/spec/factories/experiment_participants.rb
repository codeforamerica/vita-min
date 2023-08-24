# == Schema Information
#
# Table name: experiment_participants
#
#  id            :bigint           not null, primary key
#  record_type   :string           not null
#  treatment     :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  experiment_id :bigint
#  record_id     :bigint           not null
#
# Indexes
#
#  index_experiment_participants_on_experiment_id  (experiment_id)
#  index_experiment_participants_on_record         (record_type,record_id)
#
FactoryBot.define do
  factory :experiment_participant do
    experiment
  end
end
