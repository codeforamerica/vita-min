class CreateAbandonedPreConsentIntakes < ActiveRecord::Migration[7.0]
  def change
    create_table :abandoned_pre_consent_intakes do |t|
      t.string :source
      t.bigint :client_id

      t.timestamps
    end
  end
end
