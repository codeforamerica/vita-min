class AddUsedItinCertifyingAcceptanceAgentToIntakes < ActiveRecord::Migration[6.1]
  def change
    add_column :intakes, :used_itin_certifying_acceptance_agent, :boolean, default: false, null: false
  end
end
