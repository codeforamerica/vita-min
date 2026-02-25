# == Schema Information
#
# Table name: doc_assessments
#
#  id                :bigint           not null, primary key
#  error             :text
#  prompt_version    :string           default("v1"), not null
#  raw_response_json :jsonb            not null
#  result_json       :jsonb            not null
#  status            :string           default("pending"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  document_id       :bigint           not null
#  input_blob_id     :bigint           not null
#  model_id          :string
#
# Indexes
#
#  index_doc_assessments_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#
FactoryBot.define do
  factory :doc_assessment do
    association :document, factory: [:document]

    prompt_version    { BedrockDocScreener::PROMPT_VERSION }
    model_id          { BedrockDocScreener::MODEL_ID }
    raw_response_json { {} }
    result_json       { {} }
    input_blob_id     { document.upload.blob_id }

    trait :with_json do
      raw_response_json do
        {
          "id" => "msg_bdrk_idxxxxxx",
          "role" => "assistant",
          "type" => "message",
          "model" => "claude-haiku-4-5-20251001",
          "usage" => {
            "input_tokens" => 17_728,
            "output_tokens" => 90,
            "cache_creation" => {
              "ephemeral_1h_input_tokens" => 0,
              "ephemeral_5m_input_tokens" => 0
            },
            "cache_read_input_tokens" => 0,
            "cache_creation_input_tokens" => 0
          },
          "content" => [
            {
              "text" =>
                <<~TEXT,
                  ```json
                  {
                    "verdict": "pass",
                    "reason": "",
                    "explanation": "This Form W-2 (Wage and Tax Statement) doc is valid.",
                    "confidence": 0.99
                  }
                  ```
                TEXT
              "type" => "text"
            }
          ],
          "stop_reason" => "end_turn",
          "stop_sequence" => nil
        }
      end

      result_json do
        {
          "reason" => "",
          "verdict" => "pass",
          "confidence" => 0.99,
          "explanation" => "This Form W-2 (Wage and Tax Statement) doc is valid"
        }
      end
    end

    trait :complete do
      status { "complete" }
    end

    trait :pass do
      complete
      result_json do
        {
          "matches_doc_type_verdict" => "pass",
          "confidence" => 0.99
        }
      end
    end

    trait :fail do
      complete
      result_json do
        {
          "matches_doc_type_verdict" => "fail",
          "confidence" => 0.25
        }
      end
    end

    trait :attention do
      complete
      result_json { {} } # no verdict key → attention state
    end

    trait :processing do
      status { "processing" }
      result_json { {} }
    end

    trait :failed do
      status { "failed" }
      error  { "Something went wrong" }
      result_json { {} }
    end
  end
end
