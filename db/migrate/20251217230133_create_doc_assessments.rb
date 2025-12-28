class CreateDocAssessments < ActiveRecord::Migration[7.1]
  def change
    create_table :doc_assessments do |t|
      t.references :document, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :model_id
      t.string :prompt_version, null: false, default: "v1"

      # ties to the exact uploaded file/active-storage blob
      t.bigint :input_blob_id, null: false

      # outputs
      t.jsonb :result_json, null: false, default: {}
      t.jsonb :raw_response_json, null: false, default: {}
      t.text  :error

      t.timestamps
    end
  end
end
