require 'csv'

class ZendeskCli
  class ImportUsers
    include Thor::Shell

    DEFAULT_GROUP_NAME = "Support"
    INTAKE_VIEWS_GROUP_NAME = "Do Not Assign - Online Intake Views"
    SPREADSHEET_ROLE_TO_ZENDESK_ROLE = {
      "Admin" => "VITA Staff",
      "Site Coordinator" => "VITA Staff",
      "Intake Specialist" => "VITA Staff",
      "Volunteer" => "VITA Staff",
      "Customer Support Advocate" => "VITA Staff",
      "Limited Volunteer" => "VITA Staff (assigned tickets only)",
    }

    def self.from_csv(csv_path)
      rows = CSV.open(Rails.root.join(csv_path), 'r', headers: :first_row)
      normalized = rows
        .find_all { |row| row.fields.any?(&:present?) }
        .tap { |rows| rows.each { |row| row.fields.each { |f| f&.strip! } } }
      new(normalized)
    end

    def initialize(spreadsheet_contents)
      @users = spreadsheet_contents.map { |row| ZendeskUserCSVRow.from_row(row) }
      @yes_to_all = false
    end

    # This main loop handles the main logic. Methods called from here can
    # `throw(:exit)` to exit the script or `throw(:next_user)` to indicate that
    # the remaining actions for the current user should be skipped.
    def import_all
      catch(:exit) do
        @users.each_with_index do |user, i|
          catch(:next_user) do
            say ""
            say "==== USER #{i + 1} / #{@users.length} ================================"
            say "User: #{user.first_name} #{user.last_name}"
            say "Email: #{user.email}"
            say "Role: #{user.role}"
            say "Site Access: #{user.site_access}"

            # Initial check that the spreadsheet row is valid
            exit_if_user_invalid(user) unless user.valid?

            # Find the custom role that the user should be assigned (e.g. "VITA Staff").
            zendesk_role = find_zendesk_role(SPREADSHEET_ROLE_TO_ZENDESK_ROLE[user.role])

            # Find (or create) an array of groups that the user should belong to.
            zendesk_groups = find_or_create_zendesk_groups(user.site_access.split(/,|\n/))
            zendesk_groups.push(intake_views_group)

            # We now have all the dependent objects. Find (or create) the user.
            zendesk_user = find_or_create_user(user, zendesk_role)

            # After the user is created, we can create the groups
            add_and_remove_user_groups(zendesk_user, zendesk_groups)
          end
        end
      end
    end

    # @param [ZendeskUserCSVRow] user The invalid user.
    def exit_if_user_invalid(user)
      error "Error: Spreadsheet row is invalid: #{user.errors.full_messages.join(", ")}"
      yes?("Exit?") ? throw(:exit) : throw(:next_user)
    end

    # @param [String] role_name The name of the role for the user.
    # @return [ZendeskAPI::Role]
    def find_zendesk_role(role_name)
      zendesk_role = zendesk_custom_roles.find { |r| r.name == role_name }
      unless zendesk_role
        error "Error: Could not find custom role in Zendesk: #{role_name}"
        yes?("Exit?") ? throw(:exit) : throw(:next_user)
      end
      zendesk_role
    end

    # @param [Array<String>] group_names List of names of groups the user should
    #   be added to.
    # @return [ZendeskAPI::Group] Existing or newly created Zendesk groups.
    def find_or_create_zendesk_groups(group_names)
      group_names.map do |group_name|
        unless (group = zendesk_groups.find { |g| g.name == group_name })
          if yes?("Warning: Could not find group in Zendesk #{group_name}. Create?")
            group = create_group(group_name)
          else
            next
          end
        end

        group
      end.compact
    end

    # @param [ZendeskUserCSVRow] user User to find or create.
    # @return [ZendeskAPI::User] Created or updated user.
    def find_or_create_user(user, zendesk_role)
      # Find existing or create user
      existing_user ||= client.users.search(query: "email:#{user.email}").first
      zendesk_user = existing_user || client.users.build
      zendesk_user.name = "#{user.first_name} #{user.last_name}"
      zendesk_user.role = "agent"
      zendesk_user.email = user.email.downcase
      zendesk_user.custom_role_id = zendesk_role.id

      # Confirm changes
      if !zendesk_user.changed?
        say "No changes detected. Skipping."
      elsif zendesk_user.new_record?
        say ""
        say "Will create user:"
        zendesk_user.attributes.changes.each do |attribute_name, value|
          say "  * #{attribute_name}: #{value}"
        end
        if yes?("Confirm")
          zendesk_user.save
        else
          # We skip the rest of the processing for this user, if we don't create
          # them.
          throw(:next_user)
        end
      else
        zendesk_user_url = URI(zendesk_user.url).tap { |u| u.path = "/users/#{zendesk_user.id}" }
        say ""
        say "Will update user (#{zendesk_user_url}):"
        zendesk_user.attributes.changes.each do |attribute_name, value|
          say "  * #{attribute_name}: #{value}"
        end
        zendesk_user.save if yes?("Confirm")
      end
      if zendesk_user.errors.present?
        error "Error. Skipping to next user."
        error "Error Message(s): #{zendesk_user.errors}"
        throw(:next_user)
      end

      zendesk_user
    end

    # @param [ZendeskAPI::User] zendesk_user User to add/remove groups from.
    # @param [Array<ZendeskAPI::Group>] zendesk_groups The complete list of
    #   groups that the user should have access to.
    def add_and_remove_user_groups(zendesk_user, zendesk_groups)
      # To make sure we get the default group membership, we need to reload the
      # user from the API:
      zendesk_user.reload!

      # Calculate the diff of the user's current groups (zendesk_user.groups)
      # with the expected groups for the user (zendesk_groups).
      zendesk_groups_to_add = zendesk_groups.map(&:name) - zendesk_user.groups.map(&:name)
      zendesk_groups_to_remove = zendesk_user.groups.map(&:name) - zendesk_groups.map(&:name)
      if zendesk_groups_to_add.any? || zendesk_groups_to_remove.any?
        say "Groups To Add: #{zendesk_groups_to_add}"
        say "Groups To Remove: #{zendesk_groups_to_remove}"

        if yes?("Confirm group updates?")
          zendesk_groups_to_add.each_with_index do |group_name, i|
            # Add groups, setting the first one as the "default group"
            group = zendesk_group_by_name(group_name)
            client.group_memberships.create(
              user_id: zendesk_user.id,
              group_id: group.id,
              default: i == 0
            )
          end

          # Remove groups
          zendesk_groups_to_remove.each do |group_name|
            group = zendesk_group_by_name(group_name)
            zendesk_user
              .group_memberships
              .detect { |gm| gm.group_id == group.id }
              &.destroy
          end
        end
      end
    end

    def zendesk_group_by_name(name)
      zendesk_groups.find { |g| g.name == name }
    end

    # Load a cache of all Zendesk groups so we can easily search for a given
    # group by name.
    def zendesk_groups
      @zendesk_groups ||= client.groups.to_a
    end

    # Load a cache of all Zendesk custom roles so we can easily find a role by
    # name.
    def zendesk_custom_roles
      @zendesk_custom_roles ||= client.custom_roles.to_a
    end

    # This special group provides access to the "intake views" related to
    # processing online intakes.
    def intake_views_group
      @intake_views_group ||= zendesk_group_by_name(INTAKE_VIEWS_GROUP_NAME)
    end

    def yes?(message)
      if @yes_to_all
        say "#{message} [Yes to all]"
        return true
      end

      case ask("#{message} [yes/No/all]: ")
      when /\Ay|yes\z/i
        true
      when /\Aa|all\z/i
        @yes_to_all = true
        true
      when /\An|no\z/i
        false
      else
        say "Unknown input. Assuming 'no'."
        false
      end
    end

    def create_group(name)
      group = client.groups.create(name: name)

      # Add all Zendesk admins to the group
      client.users.search(role: "admin").each do |admin|
        client.group_memberships.create(user_id: admin.id, group_id: group.id)
      end

      # Reset the local cache of Zendesk groups.
      @zendesk_groups = nil

      group
    end

    def client
      @client ||= EitcZendeskInstance.client
    end
  end
end
