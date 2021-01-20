require 'csv'
require 'set'

# User importer used around 2021-01-15 to import users into demo.

class UserImporter
  def self.validate(filename)
    in_data = CSV.read(filename, headers: true)

    errors = []

    # For all email addresses, trim whitespace from before and end.
    in_data.each do |record|
      record["Email Address"] = record["Email Address"].strip unless record["Email Address"].nil?
    end

    # Check for problems first that don't require a DB query: duplicate email addresses
    seen_emails = Set.new
    in_data.each do |record|
      addr = record["Email Address"].strip
      next unless addr.present?

      errors.push(["Invalid email", "", addr]) unless ValidEmail2::Address.new(addr).valid?
      errors.push(["Duplicate email", "", addr]) if seen_emails.include?(addr)
      seen_emails.add(addr)
    end

    # Check for problems that may require a DB query. Enable query caching to avoid repeatedly looking up the same organizations/sites/coalitions.
    ActiveRecord::Base.connection.enable_query_cache!
    in_data.each do |record|
      error = validate_one(record)
      errors.push([error, "", record["Email Address"].strip.presence || "", ""]) if error.present?
    end

    puts(errors)
    puts(errors.to_json)
    puts(errors.map { |error| error.join(",") }.join("\n"))
  end

  def self.invite(filename, max_count, inviter_email)
    # If this goes wrong, we'll see in rails c, and the code will explode, so we can fix that record,
    # then delete all records before it, then re-start.
    warnings = []
    count = 0
    in_data = CSV.read(filename, headers: true)
    in_data.each do |record|
      next if record["Email Address"].strip.blank?

      record.headers.each do |key|
        record[key] = (record[key] || "").strip
      end

      if User.where(email: record["Email Address"].downcase).exists?
        warning = "Skipping #{record['Email Address']} because already exists"
        puts "W: #{warning}"
        warnings.push(warning)
        next
      end

      invite_one(record, inviter_email)
      count += 1
      if count >= max_count
        return warnings
      end
    end

    warnings
  end

  def self.validate_one(record)
    case record["Role"]
    when ""
      "Role is nil" unless record["Email Address"].blank? # fine
    when nil
      "Role is nil" unless record["Email Address"].blank? # fine
    when "Organization Lead"
      "No such organization #{record['Organization']}" unless VitaPartner.organizations.find_by_name(record["Organization"]).present?
    when "Site Coordinator"
      "Site Coordinator but No site with name #{record['Site'].presence || '(Site missing)'}" unless VitaPartner.sites.find_by_name(record["Site"]).present?
    when "Team Member/Volunteer"
      "Team Member but No site with name #{record['Site'].presence || '(Site missing)'}" unless VitaPartner.sites.find_by_name(record["Site"]).present?
    when "Coalition Lead"
      "Coalition Lead but No coalition with name #{record['Coalition'].presence || '(Site missing)'}" unless Coalition.find_by_name(record["Coalition"]).present?
    else
      "Unknown role #{record['Role']}"
    end
  end

  def self.invite_one(record, inviter_email)
    puts("Inviting #{record.to_h}")

    addr = record["Email Address"]
    raise StandardError, "Email address invalid #{addr}" unless ValidEmail2::Address.new(addr).valid?

    inviter = User.find_by!(email: inviter_email)
    if inviter.blank?
      raise StandardError, "Unable to find inviter account"
    end

    role =
      case record["Role"]
      when "Organization Lead"
        OrganizationLeadRole.new(organization: VitaPartner.organizations.find_by!(name: record["Organization"]))
      when "Site Coordinator"
        SiteCoordinatorRole.new(site: VitaPartner.sites.find_by!(name: record["Site"]))
      when "Team Member/Volunteer"
        TeamMemberRole.new(site: VitaPartner.sites.find_by!(name: record["Site"]))
      when "Coalition Lead"
        CoalitionLeadRole.new(coalition: Coalition.find_by!(name: record["Coalition"]))
      else
        raise StandardError, "Unknown role #{record['Role']}"
      end

    u = User.new(email: addr, name: "#{record['First Name']} #{record['Last Name']}", role: role, invited_by: inviter, password: SecureRandom.hex(26))
    raise StandardError, u.errors.to_h.to_s unless u.valid?

    u.save!
    u.invite!(nil, { subject: "Your Invitation to the Live / Production GetYourRefund Hub Site" })
    puts(u.inspect)
    puts(u.role.inspect)
  end
end
