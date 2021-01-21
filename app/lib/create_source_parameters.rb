require 'csv'

# Use lrzsz package to load in csv files
# https://gist.github.com/alaroia-cfa/9c28bbb5ac991fe871369c3862d00763
#
class CreateSourceParameters
  # This expects the org CSV with three columns
  # Col 1: Organization Name
  # Col 2: URL
  # Col 3: Launch Date
  def self.for_organizations(filename)
    successes = []
    problems = []
    in_data = CSV.read(filename, headers: true)

    in_data.each do |record|
      record = record.to_ary
      org_name = record[0][1]&.strip
      code = record[1][1]&.strip
      # launch_date = record[2][1]&.strip
      
      vita_partner = VitaPartner.find_by(name: org_name)
      if vita_partner.nil?
        problems << "Vita Partner with '#{org_name}' does not exist in this env. skipping."
        next
      end
      sp = SourceParameter.find_or_create_by(code: code, vita_partner_id: vita_partner.id)
      if sp.nil? || !sp.try(:persisted?)
        problems << "Could not create code #{code} for #{org_name}. Maybe it isn't unique?"
      else
        successes << "Found/created code #{code} for #{vita_partner.name}"
      end
    end
    puts "**** #{successes.length} SUCCESSES FOR THESE CODES ****"
    puts successes
    puts "**** LOOK INTO THESE #{problems.length} ISSUES ****"
    puts problems
  end

  # This expects the Site URL CSV with 3 relevant columns
  # 1: Site Name
  # 2: Organization Name
  # 3: URL
  def self.for_sites(filename)
    successes = []
    problems = []
    in_data = CSV.read(filename, headers: true)
    in_data.each do |record|
      record = record.to_ary
      org_name = record[1][1].strip

      site_name = record[0][1].gsub("\n ", "")
      code = record[2][1].strip
      vita_partner = VitaPartner.find_by(name: site_name)

      if vita_partner.nil?
        problems << "'#{site_name}' for #{org_name} cannot be found. Skipping."
        next
      end

      sp = SourceParameter.find_or_create_by(code: code, vita_partner_id: vita_partner.id)
      if sp.nil? || !sp.try(:persisted?)
        problems << "Could not create code #{code} for #{site_name}. Maybe it isn't unique?"
      else
        successes << "Found/created #{code} for #{vita_partner.name}"
      end
    end
    puts "**** #{successes.length} SUCCESSES FOR THESE CODES ****"
    puts successes
    puts "**** LOOK INTO THESE #{problems.length} ISSUES ****"
    puts problems
  end
end