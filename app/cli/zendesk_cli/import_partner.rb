class ZendeskCli
  class ImportPartner
    include Thor::Shell

    PARTNERS_YAML_PATH = Rails.root.join('db/vita_partners.yml')

    def initialize(name, source)
      @name = name
      @source = source
    end

    def find_or_create_partner
      group = find_or_create_group

      add_to_partners_yaml(group, @source)
    end

    def find_or_create_group
      if (group = find_existing_group(@name))
        say "Found existing group"
      else
        if yes?("Will create group #{@name.inspect}. Confirm (y/N)")
          group = client.groups.create(name: @name)
        end
      end

      say "Adding all admins to the group..."
      add_all_admins_to_group(group)

      group
    end

    private

    def find_existing_group(name)
      client.groups.to_a.find { |g| g.name == name }
    end

    def add_to_partners_yaml(group, source, yaml_path: PARTNERS_YAML_PATH)
      partners = YAML.load_file(yaml_path)["vita_partners"]
      partners.append(
        "name" => group.name,
        "zendesk_instance_domain" => "eitc",
        "zendesk_group_id" => group.id.to_s,
        "display_name" => group.name,
        "source_parameters" => [source].compact,
        "logo_path" => "",
      )

      File.open(PARTNERS_YAML_PATH, "w") do |f|
        f.write(YAML.dump("vita_partners" => partners))
      end
    end

    def add_all_admins_to_group(group)
      client.users.search(role: "admin").each do |admin|
        client.group_memberships.create(user_id: admin.id, group_id: group.id)
      end
    end

    def client
      @client ||= EitcZendeskInstance.client
    end
  end
end
