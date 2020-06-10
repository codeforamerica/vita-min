require 'yaml'

##
# this module upserts Vita Partner data
module VitaPartnerImporter
  VITA_PARTNERS_YAML = Rails.root.join("db/vita_partners.yml")

  ##
  # output normally except in test
  def say(message)
    puts message unless Rails.env.test?
  end

  def upsert_vita_partners(yml = VITA_PARTNERS_YAML)
    say "beginning partner upsert using environment: #{Rails.env}"

    partners = YAML.load_file(yml)['vita_partners']
    VitaPartner.transaction do
      SourceParameter.destroy_all
      partners.each do |datum|
        states = datum.delete('states')
        sources = datum.delete('source_parameters')
        partner = VitaPartner.find_by(zendesk_group_id: datum['zendesk_group_id'])
        partner = partner.present? ? update_partner(partner, datum) : create_partner(datum)
        refresh_partner_sources(partner, sources)
        refresh_partner_states(partner, states)
        say "  => done"
      end
    end
  end

  def refresh_partner_sources(partner, codes)
    return unless codes.present?

    say "  -> updating #{partner.name} source codes"
    codes.each { |code| partner.source_parameters.create!(code: code.downcase) }
  end

  def refresh_partner_states(partner, states)
    partner.states.clear
    return unless states.present?

    say "  -> updating #{partner.name} states"
    states.each { |st| partner.states << State.find_by!(abbreviation: st.upcase) }
  end

  def update_partner(partner, data)
    say "reviewing #{partner.name}"
    partner_data = partner.serializable_hash
    changed = data.filter { |k, v| partner_data[k] != v }

    changed.each { |k, v| say "updating :#{k} with #{v}" }
    say "  -> resetting to YML" unless changed.empty?
    partner.update(changed)
    partner
  end

  def create_partner(data)
    partner = VitaPartner.create(data)
    say "added #{partner.name}"
    partner
  end
end
