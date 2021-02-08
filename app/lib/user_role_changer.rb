class UserRoleChanger
  ROLE_MAP = {
    "Site Coordinator" => SiteCoordinatorRole,
    "Team Member/Volunteer" => TeamMemberRole,
    "Coalition Lead" => CoalitionLeadRole,
    "Organization Lead" => OrganizationLeadRole
  }.freeze

  def initialize(user_emails, role_type, vita_partner_name)
    @user_emails = user_emails # Array of user emails
    @pretty_role_name = role_type # String type key in role map
    @role_class = ROLE_MAP[role_type]
    raise StandardError, "Invalid role type #{role_type}" unless @role_class.present?

    @vita_partner = VitaPartner.find_by(name: vita_partner_name)
    raise StandardError, "Cannot find Vita Partner with name #{vita_partner_name}" unless @vita_partner.present?

    @warnings = []
    @successes = []
  end

  def update_all
    @user_emails.each do |email|
      user = User.find_by(email: email)
      unless user.present?
        @warnings << "Can't find user with email #{email}."
        next
      end
      current_role = user.role
      if current_role&.vita_partner_id == @vita_partner.id && current_role.class == @role_class
        @warnings << "User with email #{email} is already a #{@pretty_role_name} for #{@vita_partner.name}"
        next
      end
      new_role = @role_class.new(vita_partner_id: @vita_partner.id)
      unless new_role.valid?
        @warnings << "Could not create a valid role for #{email} / #{@vita_partner.name}: #{new_role.errors.full_messages}"
        next
      end
      if user.update(role: new_role)
        @successes << "User #{email} is now a #{@pretty_role_name.to_s} for #{@vita_partner.name}"
        current_role.destroy!
      end
    end
    puts "******* #{@successes.count} SUCCESSES***********"
    puts @successes

    puts "******* #{@warnings.count} WARNINGS ***********"
    puts @warnings
  end
end
