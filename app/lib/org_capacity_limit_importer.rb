require 'csv'

class OrgCapacityLimitImporter
  def from_csv(filename)
    # To use, run "OrgCapacityLimitImporter.from_csv('./org.csv')" in console
    successes = []
    problems = []
    unfound_vita_partners = []

    headers = CSV.foreach(filename).first

    capacity_index = 1
    org_name_index = 0
    unless headers[capacity_index]&.strip == "Starting Capacity" || headers[org_name_index]&.strip == "Organization Name"
      puts "Unable to process file b/c headers are not aligned #{headers[capacity_index]}, #{headers[org_name_index]}"
      return
    end

    data = CSV.read(filename, headers: true)

    data.map do |row|
      capacity_limit = row[capacity_index]&.strip.to_i
      next unless capacity_limit

      organization_name = row[org_name_index]&.strip
      vita_partner = VitaPartner.where(name: organization_name)&.first
      if vita_partner.nil?
        unfound_vita_partners << organization_name
        next
      end

      begin
        if vita_partner.site?
          problems << "SKIPPED Unable to update capacity limit of #{capacity_limit} for #{vita_partner&.name} because vita partner is a site"
        else
          vita_partner.update!(capacity_limit: capacity_limit)
          successes << "Updated #{vita_partner&.name} with capacity limit of #{capacity_limit}"
        end
      rescue => e
        problems << "SKIPPED Unable to update capacity limit of #{capacity_limit} for #{vita_partner&.name} because: #{ e.message }"
      end
    end

    problems << "SKIPPED Unable to find VitaPartner for organization names:\n#{unfound_vita_partners.join(", ")}"
    puts "**** #{successes.length} SUCCESSES ****"
    puts successes
    puts "**** LOOK INTO THESE #{problems.length} ISSUES ****"
    puts problems
  end
end
