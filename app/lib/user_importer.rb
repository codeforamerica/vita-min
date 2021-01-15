require 'csv'

class UserImporter
  def self.validate(filename)
    ActiveRecord::Base.connection.enable_query_cache!
    # duplicate emails
    errors = []
    in_data = CSV.read(filename, headers: true)
    in_data.each do |record|
      error = validate_one(record)
      next if error.blank?

      errors.push([error, "", record["Email Address"], "", record.to_h.to_s.sub(",", " &")].join(","))
    end

    puts(errors.join("\n"))
  end

  def self.invite(filename)
    # If this goes wrong, we'll see in rails c, and the code will explode, so we can fix that record,
    # then delete all records before it, then re-start.
    in_data = CSV.read(filename, headers: true)
    in_data.each do |datum| invite_one(datum) end
  end

  private

  def self.validate_one(record)
    case record["Role"]
    when ""
      return "Role is nil" unless record["Email Address"].blank? # fine
    when "Organization Lead"
      return "No such organization #{record["Organization"]}" unless VitaPartner.organizations.find_by_name(record["Organization"]).present?
    when "Site Coordinator"
      return "Site Coordinator but No site with name #{record["Site"].presence || '(Site missing)'}" unless VitaPartner.sites.find_by_name(record["Site"]).present?
    when "Team Member/Volunteer"
      return "Team Member but No site with name #{record["Site"].presence || '(Site missing)'}" unless VitaPartner.sites.find_by_name(record["Site"]).present?
    when "Coalition Lead"
      return "Coalition Lead but No coalition with name #{record["Coalition"].presence || '(Site missing)'}" unless Coalition.find_by_name(record["Coalition"]).present?
    else
      return "Unknown role #{record["Role"]}"
    end
  end

  def self.invite_one(record)
    puts("Inviting #{record.to_h}")

    case record["Role"]
    when ""
      raise StandardError, "Role is nil" unless record["Email Address"].blank? # fine
    when "Organization Lead"
      return StandardError, "No such organization #{record["Organization"]}" unless VitaPartner.organizations.find_by_name(record["Organization"]).present?
    when "Site Coordinator"
      raise StandardError, "Site Coordinator but No site with name #{record["Site"].presence || '(Site missing)'}" unless VitaPartner.sites.find_by_name(record["Site"]).present?
    when "Team Member/Volunteer"
      raise StandardError, "Team Member but No site with name #{record["Site"].presence || '(Site missing)'}" unless VitaPartner.sites.find_by_name(record["Site"]).present?
    when "Coalition Lead"
      raise StandardError, "Coalition Lead but No coalition with name #{record["Coalition"].presence || '(Site missing)'}" unless Coalition.find_by_name(record["Coalition"]).present?
    else
      raise StandardError, "Unknown role #{record["Role"]}"
    end
  end
end
