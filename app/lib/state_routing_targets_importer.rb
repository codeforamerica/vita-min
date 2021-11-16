require 'csv'

class StateRoutingTargetsImporter
  def from_csv(filename)
    # To use, run "StateRoutingTargetsImporter.from_csv('./wave_1_routing.csv')" in console
    successes = []
    problems = []
    unfound_vita_partners = []

    headers = CSV.foreach(filename).first

    unless headers[1]&.strip == "States can serve" || headers[0]&.strip == "Organization Name"
      puts "Unable to process file b/c headers are not aligned #{headers[0]}"
      return
    end

    data = CSV.read(filename, headers: true)

    data.map do |row|
      states = row[1]
      next unless states

      organization_name = row[0]&.strip
      vita_partner = VitaPartner.where(name: organization_name)&.first
      if vita_partner.nil?
        unfound_vita_partners << organization_name
        next
      end

      states.to_s.split(",").map do |state|
        begin
          StateRoutingTarget.create!(state: state&.strip&.upcase, vita_partner: vita_partner)
          successes << "Created StateRoutingTarget with #{state} for #{vita_partner&.name}"
        rescue => e
          problems << "SKIPPED Unable to create StateRoutingTarget with #{state} for #{vita_partner&.name} because: #{ e.message }"
        end
      end
    end

    problems << "SKIPPED Unable to find VitaPartner for organization names:\n#{unfound_vita_partners.join(", ")}"
    puts "**** #{successes.length} SUCCESSES ****"
    puts successes
    puts "**** LOOK INTO THESE #{problems.length} ISSUES ****"
    puts problems
  end
end
