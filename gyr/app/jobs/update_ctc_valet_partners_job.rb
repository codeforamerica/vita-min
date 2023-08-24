class UpdateCtcValetPartnersJob
  def self.perform
    ['StreetCred at BMC', 'United Way of Greater Nashville'].each do |org_name|
      org = VitaPartner.organizations.find_by(name: org_name)
      if org
        org.update!(processes_ctc: true)
        puts "Updated #{org_name} to accept CTC Valet clients"
        counter = 0
        org.child_sites.each_slice(10) do |sites|
          sites.each do |site|
            site.update!(processes_ctc: true)
            counter += 1
          end
        end
        puts "Updated #{counter} child sites for #{org_name}"
      else
        puts "Could not find VitaPartner named #{org_name}"
      end
    end
  end
end