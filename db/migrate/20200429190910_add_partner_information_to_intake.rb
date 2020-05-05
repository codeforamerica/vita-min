class AddPartnerInformationToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :vita_partner_name, :string

    reversible do |dir|
      dir.up do
        Intake.all.each do |intake|
          next unless intake.zendesk_group_id.present?
          partner = VitaPartner.find_by(zendesk_group_id: intake.zendesk_group_id)
          intake.update(vita_partner_name: partner.name) if partner
        end
      end
    end
  end
end
