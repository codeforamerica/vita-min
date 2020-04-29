## these tasks manage VITA partner information
require 'yaml'

namespace :db do
  desc "loads new vita partners, updates existing partners"
  task :upsert_vita_partners => :environment do
    # TODO: don't leave the next line in
    # load yaml file
    partners = YAML.load_file('db/vita_partners.yml')['vita_partners']
    partners.each do |datum|
      partner = VitaPartner.find_by(zendesk_group_id: datum['zendesk_group_id'])
      partner.present? ? update_partner_with(partner, datum) : create_partner_with(datum)
    end
  end
end

def update_partner_with(partner, data)
  print "reviewing #{partner.name} -- "
  partner_data = partner.serializable_hash
  updated_attributes = {}
  data.each do |key, val|
    if partner_data[key] != val
      # TODO: this isn't very efficient
      updated_attributes[key] = val
    end
  end

  unless updated_attributes.empty?
    puts "reverting. was:"
    p partner_data.inspect
    partner.update(updated_attributes)
    puts "now:"
    p partner.serializable_hash.inspect
  else
    puts "no change."
  end
end

def create_partner_with(data)
  p VitaPartner.create(data).inspect
end
