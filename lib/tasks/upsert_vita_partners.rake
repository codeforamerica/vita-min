## these tasks manage VITA partner information
require 'yaml'

namespace :db do
  desc 'loads new vita partners, updates existing partners'
  task upsert_vita_partners: [:environment] do
    # TODO: don't leave the next line in
    # load yaml file
    partners = YAML.load_file('db/vita_partners.yml')['vita_partners']
    partners.each do |datum|
      partner = VitaPartner.find_by(zendesk_group_id: datum['zendesk_group_id'])
      partner.present? ? update_partner(partner, datum) : create_partner(datum)
    end
  end
end

def update_partner(partner, data)
  print "reviewing #{partner.name} -- "
  partner_data = partner.serializable_hash
  changed = data.filter { |k, v| partner_data[k] != v }

  changed.each { |k, v| puts "updating :#{k} with #{v}" }
  partner.update(changed)
end

def create_partner(data)
  partner = VitaPartner.create(data).inspect
  puts "added #{partner.name}"
end
