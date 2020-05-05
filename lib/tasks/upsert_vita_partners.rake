## these tasks manage VITA partner information
require 'yaml'

namespace :db do
  desc 'loads new vita partners, updates existing partners'
  task upsert_vita_partners: [:environment] do
    puts "beginning partner upsert using environment: #{Rails.env}"
    # TODO: don't leave the next line in
    # load yaml file
    partners = YAML.load_file('db/vita_partners.yml')['vita_partners']
    partners.each do |datum|
      states = datum.delete('states')
      sources = datum.delete('source_parameters')
      partner = VitaPartner.find_by(zendesk_group_id: datum['zendesk_group_id'])
      partner = partner.present? ? update_partner(partner, datum) : create_partner(datum)
      refresh_partner_sources(partner, sources)
      refresh_partner_states(partner, states)
      puts "  => done"
    end
  end
end

def refresh_partner_sources(partner, codes)
  partner.source_codes.destroy_all
  return unless codes.present?
  puts "  -> updating #{partner.name} source codes"

  codes.each { |code| partner.source_codes.find_or_create_by!(code: code.downcase, vita_partner_id: partner.id) }
end

def refresh_partner_states(partner, states)
  partner.states.clear
  return unless states.present?
  puts "  -> updating #{partner.name} states"

  states.each { |st| partner.states << State.find_by!(abbreviation: st.upcase) }
end

def update_partner(partner, data)
  puts "reviewing #{partner.name}"
  partner_data = partner.serializable_hash
  changed = data.filter { |k, v| partner_data[k] != v }

  changed.each { |k, v| puts "updating :#{k} with #{v}" }
  puts "  -> resetting to YML" unless changed.empty?
  partner.update(changed)
  puts "done"
  return partner
end

def create_partner(data)
  partner = VitaPartner.create(data)
  puts "added #{partner.name}"
  return partner
end
