# == Schema Information
#
# Table name: clients
#
#  id                                       :bigint           not null, primary key
#  attention_needed_since                   :datetime
#  completion_survey_sent_at                :datetime
#  current_sign_in_at                       :datetime
#  current_sign_in_ip                       :inet
#  failed_attempts                          :integer          default(0), not null
#  first_unanswered_incoming_interaction_at :datetime
#  flagged_at                               :datetime
#  in_progress_survey_sent_at               :datetime
#  last_incoming_interaction_at             :datetime
#  last_internal_or_outgoing_interaction_at :datetime
#  last_outgoing_communication_at           :datetime
#  last_sign_in_at                          :datetime
#  last_sign_in_ip                          :inet
#  locked_at                                :datetime
#  login_requested_at                       :datetime
#  login_token                              :string
#  routing_method                           :integer
#  sign_in_count                            :integer          default(0), not null
#  still_needs_help                         :integer          default("unfilled"), not null
#  triggered_still_needs_help_at            :datetime
#  created_at                               :datetime         not null
#  updated_at                               :datetime         not null
#  vita_partner_id                          :bigint
#
# Indexes
#
#  index_clients_on_in_progress_survey_sent_at  (in_progress_survey_sent_at)
#  index_clients_on_login_token                 (login_token)
#  index_clients_on_vita_partner_id             (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
FactoryBot.define do
  factory :client do
    trait :with_return do
      transient do
        status { "intake_in_progress" }
      end
      after(:create) do |client, evaluator|
        create :tax_return, client: client, status: evaluator.status
      end
    end

    factory :client_with_status do
      with_return
    end

    trait :with_empty_consent do
      after(:build) do |client|
        create :consent,
               client: client,
               disclose_consented_at: nil,
               use_consented_at: nil,
               global_carryforward_consented_at: nil,
               relational_efin_consented_at: nil
      end
    end

    trait :with_consent do
      after(:build) do |client|
        create :consent, client: client
      end
    end

    factory :client_with_intake_and_return do
      with_return
      transient do
        preferred_name { "Maeby" }
      end
      after(:create) do |client, evaluator|
        create :intake, client: client, preferred_name: evaluator.preferred_name
      end
    end
  end
end
