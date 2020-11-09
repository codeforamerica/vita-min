require 'yaml'

class VitaPartnerImporter < CliScriptBase
  VITA_PARTNERS_YAML = Rails.root.join("db/vita_partners.yml")

  def self.upsert_vita_partners(yml = VITA_PARTNERS_YAML)
    report_progress "beginning partner upsert using environment: #{Rails.env}"

    yaml_partners = YAML.load_file(yml)['vita_partners']
    yaml_zendesk_group_ids = yaml_partners.map { |partner| partner["zendesk_group_id"] }
    yaml_partners.each do |yaml_partner|
      upsert_vita_partner(yaml_partner)
    end
    archive_absent_partners(VitaPartner.where.not(zendesk_group_id: yaml_zendesk_group_ids))
    report_progress "  => done"
  end

  private

  def self.upsert_vita_partner(yaml_partner)
    # Make sure there is a VITA partner in the DB for this zendesk_group_id
    db_partner = VitaPartner.find_by(zendesk_group_id: yaml_partner['zendesk_group_id'])
    if db_partner.nil?
      db_partner = VitaPartner.new(zendesk_group_id: yaml_partner['zendesk_group_id'])
    end

    # Update it
    db_partner.accepts_overflow = yaml_partner["accepts_overflow"]
    db_partner.display_name = yaml_partner["display_name"]
    db_partner.logo_path = yaml_partner["logo_path"]
    db_partner.name = yaml_partner["name"]
    db_partner.weekly_capacity_limit = yaml_partner["weekly_capacity_limit"]
    db_partner.zendesk_instance_domain = yaml_partner["zendesk_instance_domain"]
    db_partner.save!

    db_partner.source_parameters.destroy(db_partner.source_parameters)
    yaml_partner["source_parameters"].each { |code| db_partner.source_parameters.create!(code: code.downcase) } if yaml_partner["source_parameters"].present?

    db_partner.states.clear
    yaml_partner["states"].each { |st| db_partner.states << State.find_by!(abbreviation: st.upcase) } if yaml_partner["states"].present?

    db_partner.save!
  end

  def self.archive_absent_partners(db_partners)
    db_partners.update_all(archived: true)
    db_partners.each do |db_partner|
      # This removes the source parameter. If you need a list of all historically-used source parameters, do a query
      # against Intake objects.
      db_partner.source_parameters.destroy(db_partner.source_parameters)
      db_partner.states.clear
    end
  end
end
