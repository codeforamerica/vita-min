require "rails_helper"

# Create a class to stub in for Thor's `shell` so we can avoid stdout/stderr
# going to console, and also assert the contents of stdout/stderr.
class TestShell < Thor::Shell::Basic
  def stdout
    @stdout ||= StringIO.new
  end

  def stderr
    @stderr ||= StringIO.new
  end
end

RSpec.describe ZendeskCli::ImportUsers do
  let(:shell) { TestShell.new }
  let(:mock_client) do
    double(
      "ZendeskAPI::Client",
      users: double(build: ZendeskAPI::User.new(nil), search: existing_zendesk_users),
      groups: double(create: nil, to_a: existing_zendesk_groups.dup),
      custom_roles: existing_zendesk_custom_roles,
      group_memberships: double(create: true),
    )
  end
  let(:intake_view_group) { double("ZendeskAPI::Group", id: 4444, name: described_class::INTAKE_VIEWS_GROUP_NAME) }
  let(:existing_zendesk_groups) do
    [
      double("ZendeskAPI::Group", id: 1111, name: "Test Zendesk Site"),
      double("ZendeskAPI::Group", id: 2222, name: "Other Zendesk Site"),
      double("ZendeskAPI::Group", id: 3333, name: "Yet Another Zendesk Site"),
      intake_view_group,
    ]
  end
  let(:existing_zendesk_custom_roles) { [double("ZendeskAPI::Role", id: 1234, name: "VITA Staff")] }
  let(:existing_zendesk_users) { [] }

  before do
    allow_any_instance_of(described_class).to receive(:client).and_return(mock_client)
    allow_any_instance_of(described_class).to receive(:shell).and_return(shell)
  end

  describe "#import_all" do
    let(:importer) { described_class.new(user_rows) }
    let(:user_rows) { [] }

    context "with a valid user to import" do
      let(:valid_user) do
        ZendeskUserCSVRow.to_row(
          first_name: "Betsy",
          last_name: "Basil",
          email: "betsy@example.com",
          role: "Admin",
          site_access: "Test Zendesk Site,Other Zendesk Site"
        )
      end
      let(:user_rows) { [valid_user] }
      let(:mock_zendesk_user) { double("ZendeskAPI::User") }

      it "calls the other methods with expected arguments" do
        user_groups = existing_zendesk_groups.first(2)
        user_role = existing_zendesk_custom_roles.first

        expect(importer).not_to receive(:exit_if_user_invalid)
        expect(importer).to receive(:find_zendesk_role).with("VITA Staff").and_return(user_role)
        expect(importer).to receive(:find_or_create_zendesk_groups)
          .with(["Test Zendesk Site", "Other Zendesk Site"])
          .and_return(user_groups.dup)
        expect(importer).to receive(:find_or_create_user).with(
          have_attributes(first_name: "Betsy", email: "betsy@example.com"),
          user_role
        ).and_return(mock_zendesk_user)
        expect(importer).to receive(:add_and_remove_user_groups).with(
          mock_zendesk_user,
          user_groups + [intake_view_group]
        )

        importer.import_all
      end
    end

    context "when given an invalid user row" do
      let(:invalid_user) do
        ZendeskUserCSVRow.to_row(
          first_name: nil,
          last_name: "Basil",
        )
      end
      let(:user_rows) { [invalid_user] }

      before do
        allow(importer).to receive(:exit_if_user_invalid).and_throw(:exit)
      end

      it "asks the user to exit" do
        expect(importer).to receive(:exit_if_user_invalid).with(have_attributes(last_name: "Basil"))
        importer.import_all
      end
    end
  end

  describe "#find_zendesk_role" do
    context "when the role exists" do
      it "returns the role" do
        role = described_class.new([]).find_zendesk_role(existing_zendesk_custom_roles.first.name)
        expect(role).to eq(existing_zendesk_custom_roles.first)
      end
    end

    context "when the role is missing from Zendesk" do
      let(:nonexistent_role) { "Non-Existent Role" }

      it "asks the user to exit" do
        importer = described_class.new([])
        expect(importer).to receive(:yes?).with("Exit?").and_return(true)
        expect { importer.find_zendesk_role(nonexistent_role) }.to throw_symbol(:exit)
        expect(shell.stderr.string).to include("Could not find custom role in Zendesk: #{nonexistent_role}")
      end
    end
  end

  describe "#find_or_create_zendesk_groups" do
    let(:existing_group_names) { existing_zendesk_groups.first(2).map(&:name) }

    context "when the groups exist" do
      it "returns an array of group objects" do
        importer = described_class.new([])
        result = importer.find_or_create_zendesk_groups(existing_group_names)
        expect(result).to eq(existing_zendesk_groups.first(2))
      end
    end

    context "when a group does not exist" do
      let(:nonexistent_group) { double("ZendeskAPI::Group", name: "Some New Group Name") }
      let(:group_names) { existing_group_names + [nonexistent_group.name] }

      it "creates the group if the user says yes" do
        importer = described_class.new([])
        expect(importer).to receive(:yes?).with(end_with("Create?")).and_return(true)
        expect(importer).to receive(:create_group)
          .with(nonexistent_group.name)
          .and_return(nonexistent_group)

        result = importer.find_or_create_zendesk_groups(group_names)
        expect(result).to eq(existing_zendesk_groups.first(2) + [nonexistent_group])
      end

      it "does not create the group if the user says no" do
        importer = described_class.new([])
        expect(importer).to receive(:yes?).with(end_with("Create?")).and_return(false)
        expect(importer).not_to receive(:create_group)

        result = importer.find_or_create_zendesk_groups(group_names)
        expect(result).to eq(existing_zendesk_groups.first(2))
      end
    end
  end

  describe "#find_or_create_user" do
    let(:csv_user) do
      ZendeskUserCSVRow.new(
        first_name: "Betsy",
        last_name: "Basil",
        email: "betsy@example.com",
        role: "Admin",
        site_access: "Test Zendesk Site,Other Zendesk Site"
      )
    end

    context "when the user is new" do
      it "creates the user" do
        importer = described_class.new([])
        expect(importer).to receive(:yes?).with("Confirm").and_return(true)
        expect_any_instance_of(ZendeskAPI::User).to receive(:save)
        expect(mock_client.users).to receive(:search).with(query: "email:betsy@example.com").and_return([])

        result = importer.find_or_create_user(csv_user, existing_zendesk_custom_roles.first)
        expect(result).to be_a(ZendeskAPI::User)
        expect(result).to have_attributes(name: "Betsy Basil")
        expect(shell.stdout.string).to match(/Will create user:/)
        expect(shell.stdout.string).to include("* name: Betsy Basil")
      end

      it "skips to the next user if the person running does not confirm" do
        importer = described_class.new([])
        expect(importer).to receive(:yes?).with("Confirm").and_return(false)
        expect_any_instance_of(ZendeskAPI::User).not_to receive(:save)
        expect(mock_client.users).to receive(:search).with(query: "email:betsy@example.com").and_return([])

        expect do
          importer.find_or_create_user(csv_user, existing_zendesk_custom_roles.first)
        end.to throw_symbol(:next_user)
      end
    end

    context "when the user exists already" do
      let(:zendesk_user) do
        ZendeskAPI::User.new(
          nil,
          id: 112233,
          name: "Barbara Basil",
          role: "agent",
          email: "betsy@example.com",
          custom_role_id: existing_zendesk_custom_roles.first.id,
          url: "http://eitc.zendesk.com/api/user/112233.json"
        )
      end
      let(:existing_zendesk_users) { [zendesk_user] }

      before do
        allow(zendesk_user).to receive(:save)
      end

      it "updates the user's attributes that have changed and returns the user" do
        importer = described_class.new([])
        expect(importer).to receive(:yes?).with("Confirm").and_return(true)
        expect(zendesk_user).to receive(:save)
        expect(mock_client.users).to receive(:search).with(query: "email:betsy@example.com")

        result = importer.find_or_create_user(csv_user, existing_zendesk_custom_roles.first)

        expect(result).to eq(zendesk_user)
        expect(shell.stdout.string).to match(/Will update user.*112233/)
        expect(shell.stdout.string).to include("* name: Betsy Basil")
      end
    end
  end

  describe "#add_and_remove_user_groups" do
    let(:zendesk_user) do
      ZendeskAPI::User.new(
        nil,
        id: 998877,
      )
    end
    let(:already_in_groups) { existing_zendesk_groups.first(2) }

    before do
      allow(zendesk_user).to receive(:reload!)
      allow(zendesk_user).to receive(:groups).and_return(already_in_groups)
      allow(zendesk_user).to receive(:group_memberships).and_return(
        already_in_groups.map do |g|
          ZendeskAPI::GroupMembership.new(nil, group_id: g.id)
        end
      )
    end

    context "when the user is not in a group it is expected to be" do
      let(:group_needs_added_to) { existing_zendesk_groups.last }

      it "adds the user to that group" do
        importer = described_class.new([])
        expect(importer).to receive(:yes?).with("Confirm group updates?").and_return(true)
        expect(mock_client.group_memberships).to receive(:create).with(
          user_id: 998877,
          group_id: group_needs_added_to.id,
          default: true,
        )

        importer.add_and_remove_user_groups(zendesk_user, already_in_groups + [group_needs_added_to])
        expect(shell.stdout.string).to include("Groups To Add: [#{group_needs_added_to.name.inspect}]")
        expect(shell.stdout.string).to include("Groups To Remove: []")
      end
    end

    context "when the user is in a group that it shouldn't be" do
      let(:group_to_remove) { already_in_groups.last }

      it "removes the user from that group" do
        importer = described_class.new([])
        expect(importer).to receive(:yes?).with("Confirm group updates?").and_return(true)
        expect(zendesk_user.group_memberships.last).to receive(:destroy)

        importer.add_and_remove_user_groups(zendesk_user, already_in_groups - [group_to_remove])
        expect(shell.stdout.string).to include("Groups To Add: []")
        expect(shell.stdout.string).to include("Groups To Remove: [#{group_to_remove.name.inspect}]")
      end
    end
  end

  describe "#create_group" do
    let(:new_group_name) { "Some New Group Name" }
    let(:mock_group) { double("ZendeskAPI::Group", id: 8765, name: new_group_name) }
    let(:admin_users) { [] }

    before do
      allow(mock_client.users).to receive(:search).with(role: "admin").and_return(admin_users)
      allow(mock_client.groups).to receive(:create).with(name: new_group_name).and_return(mock_group)
    end

    it "creates the group" do
      importer = described_class.new([])
      expect(mock_client.groups).to receive(:create).with(name: new_group_name)

      result = importer.create_group(new_group_name)
      expect(result).to eq(mock_group)
    end

    it "clears the cache of zendesk_groups" do
      importer = described_class.new([])
      expect(mock_client.groups).to receive(:create).with(name: new_group_name)
      expect(importer.zendesk_groups).not_to include(mock_group)

      # Simulate creating the group and updating the API results to include the
      # new record.
      importer.create_group(new_group_name)
      allow(mock_client.groups).to receive(:to_a).and_return(existing_zendesk_groups + [mock_group])

      expect(importer.zendesk_groups).to include(mock_group)
    end

    context "when there are admins returned from search" do
      let(:admin_users) { [double("ZendeskAPI::User", id: 4455)] }

      it "adds all admins to the group" do
        importer = described_class.new([])
        expect(mock_client.group_memberships).to receive(:create)
          .with(user_id: admin_users.first.id, group_id: mock_group.id)

        importer.create_group(new_group_name)
      end
    end
  end
end
