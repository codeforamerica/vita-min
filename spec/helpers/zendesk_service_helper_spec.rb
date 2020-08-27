require "rails_helper"

RSpec.describe ZendeskServiceHelper do
  let(:fake_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 2) }
  let(:fake_zendesk_user) { double(ZendeskAPI::User, id: 1) }
  let(:fake_zendesk_comment) { double(uploads: []) }
  let(:fake_zendesk_comment_body) { "" }
  let(:service) do
    class SampleService
      include ZendeskServiceHelper

      def instance
        EitcZendeskInstance
      end
    end

    SampleService.new
  end
  let(:qualified_environments) { service.qualified_environments }
  let(:unqualified_environments) { %w[test production] }

  before do
    allow(ZendeskAPI::Client).to receive(:new).and_return fake_zendesk_client
    allow(ZendeskAPI::Ticket).to receive(:new).and_return fake_zendesk_ticket
    allow(ZendeskAPI::Ticket).to receive(:find).and_return fake_zendesk_ticket
    allow(fake_zendesk_comment).to receive(:body).and_return(fake_zendesk_comment_body)
    allow(fake_zendesk_comment_body).to receive(:concat)
    allow(fake_zendesk_ticket).to receive(:comment=)
    allow(fake_zendesk_ticket).to receive(:fields=)
    allow(fake_zendesk_ticket).to receive(:tags).and_return ["old_tag"]
    allow(fake_zendesk_ticket).to receive(:tags=)
    allow(fake_zendesk_ticket).to receive(:group_id=)
    allow(fake_zendesk_ticket).to receive(:comment).and_return fake_zendesk_comment
    allow(fake_zendesk_ticket).to receive(:save!)
  end

  describe "#create_or_update_zendesk_user" do
    before do
      allow(ZendeskAPI::User).to receive(:create_or_update!).with(
        service.client,
        hash_including(
          name: kind_of(String),
          verified: true,
        )
      ).and_return(fake_zendesk_user)
    end

    context "with valid arguments" do
      context "with minimal arguments" do
        let(:arguments) do
          { name: "Olayo Orange", email: nil, phone: "+15554441111" }
        end

        it "returns the user id" do
          result = service.create_or_update_zendesk_user(**arguments)

          expect(result).to eq 1
        end
      end

      context "with all arguments" do
        let(:arguments) do
          { name: "Olayo Orange", email: "example@example.com", phone: "+15554441111", time_zone: "Chicago" }
        end

        it "passes them all to Zendesk" do
          service.create_or_update_zendesk_user(**arguments)
          expect(ZendeskAPI::User).to have_received(:create_or_update!).with(service.client, {
            name: "Olayo Orange",
            verified: true,
            email: "example@example.com",
            phone: "+15554441111",
            time_zone: "Chicago"
          })
        end
      end

      context "with blank or missing optional attributes" do
        let(:arguments) do
          { name: "Olayo Orange", email: "", phone: "+15554441111" }
        end

        it "does not pass optional arguments to zendesk if they are blank or missing" do
          service.create_or_update_zendesk_user(**arguments)
          expect(ZendeskAPI::User).to have_received(:create_or_update!).with(service.client, {
            name: "Olayo Orange",
            verified: true,
            phone: "+15554441111",
          })
        end
      end
    end

    context "with invalid arguments" do
      context "with a blank name argument" do
        let(:arguments) do
          { name: nil, phone: "+15554441111" }
        end

        it "raises an error" do
          expect { service.create_or_update_zendesk_user(**arguments) }.to raise_error(StandardError)
          expect(ZendeskAPI::User).not_to have_received(:create_or_update!)
        end
      end

      context "if missing both email and phone" do
        let(:arguments) do
          { name: "Olayo Orange" }
        end

        it "raises an error" do
          expect { service.create_or_update_zendesk_user(**arguments) }.to raise_error(StandardError)
          expect(ZendeskAPI::User).not_to have_received(:create_or_update!)
        end
      end
    end

    context "modifying names per environment" do
      let(:arguments) do
        { name: "Olayo Orange", email: "example@example.com" }
      end

      context "in an environment other than production or test" do
        before { allow(Rails).to receive(:env).and_return("demo".inquiry) }

        it "appends (Fake User) to the preferred user name" do
          service.create_or_update_zendesk_user(**arguments)
          expect(ZendeskAPI::User).to have_received(:create_or_update!).with(service.client, {
              name: "Olayo Orange (Fake User)",
              verified: true,
              email: "example@example.com",
          })
        end
      end

      context "in production or test" do
        before { allow(Rails).to receive(:env).and_return("production".inquiry) }

        it "passes in preferred name with no edits" do
          service.create_or_update_zendesk_user(**arguments)
          expect(ZendeskAPI::User).to have_received(:create_or_update!).with(service.client, {
              name: "Olayo Orange",
              verified: true,
              email: "example@example.com",
          })
        end
      end
    end
  end

  describe "#build_ticket" do
    let(:ticket_args) do
      {
        subject: "wyd",
        requester_id: 4,
        group_id: "123409218",
        body: "What's up?",
        fields: {
          "09182374" => "not_busy"
        }
      }
    end

    it "correctly calls the Zendesk API and returns a ticket object" do
      result = service.build_ticket(**ticket_args)

      expect(result).to eq fake_zendesk_ticket
      expect(ZendeskAPI::Ticket).to have_received(:new).with(
        fake_zendesk_client,
        {
          subject: "wyd",
          requester_id: 4,
          group_id: "123409218",
          external_id: nil,
          comment: {
            body: "What's up?",
          },
          fields: [
            "09182374" => "not_busy"
          ]
        }
      )
    end
  end

  describe "#create_ticket" do
    let(:success) { true }
    let(:ticket_args) do
      {
        subject: "wyd",
        requester_id: 4,
        group_id: "123409218",
        external_id: "some-object-123",
        body: "What's up?",
        fields: {
          "09182374" => "not_busy"
        }
      }
    end

    before do
      allow(service).to receive(:build_ticket).and_return(fake_zendesk_ticket)
      allow(fake_zendesk_ticket).to receive(:save!).and_return(success)
    end

    it "calls build_ticket, saves the ticket, and returns the ticket id" do
      result = service.create_ticket(**ticket_args)
      expect(result).to eq fake_zendesk_ticket
      expect(fake_zendesk_ticket).to have_received(:save!).with(no_args)
      expect(service).to have_received(:build_ticket).with(**ticket_args)
    end
  end

  describe "#assign_ticket_to_group" do
    it "finds the ticket and updates the group id" do
      service.assign_ticket_to_group(ticket_id: 123, group_id: "12543")

      expect(fake_zendesk_ticket).to have_received(:group_id=).with("12543")
      expect(fake_zendesk_ticket).to have_received(:save!).with(no_args)
    end
  end

  describe "#append_file_to_ticket" do
    let(:file) { instance_double(File) }

    before do
      allow(file).to receive(:size).and_return(1000)
    end

    it "calls the Zendesk API to get the ticket and add the comment with upload and returns true" do
      service.append_file_to_ticket(
        ticket_id: 1141,
        filename: "wyd.jpg",
        file: file,
        comment: "hey",
        fields: { "314324132" => "custom_field_value" }
      )
      expect(fake_zendesk_ticket).to have_received(:comment=).with({ body: "hey" })
      expect(fake_zendesk_ticket).to have_received(:fields=).with({ "314324132" => "custom_field_value" })
      expect(fake_zendesk_comment.uploads).to include({file: file, filename: "wyd.jpg"})
      expect(fake_zendesk_ticket).to have_received(:save!)
    end

    context "when the ticket id is missing" do
      it "raises an error" do
        expect do
          service.append_file_to_ticket(
            ticket_id: nil,
            filename: "yolo.pdf",
            file: file
          )
        end.to raise_error(ZendeskServiceHelper::MissingTicketIdError)
      end
    end

    context "when the file exceeds the maximum size" do
      let(:oversize_file) { instance_double(File) }

      before do
        allow(oversize_file).to receive(:size).and_return(100000000)
      end

      it "does not append the file" do
        service.append_file_to_ticket(
          ticket_id: 1141,
          filename: "big.jpg",
          file: oversize_file,
          comment: "hey",
          fields: { "314324132" => "custom_field_value" }
        )
        expect(fake_zendesk_comment.uploads).not_to include({file: oversize_file, filename: "big.jpg"})
      end

      it "adds an oversize file message to the comment" do
        service.append_file_to_ticket(
          ticket_id: 1141,
          filename: "big.jpg",
          file: oversize_file,
          comment: "hey",
          fields: { "314324132" => "custom_field_value" }
        )
        expect(fake_zendesk_comment_body).to have_received(:concat).with("\n\nThe file big.jpg could not be uploaded because it exceeds the maximum size of 20MB.")
        expect(fake_zendesk_ticket).to have_received(:save!)
      end
    end
  end

  describe "#append_multiple_files_to_ticket" do
    let(:file_1) { instance_double(File) }
    let(:file_2) { instance_double(File) }
    let(:file_3) { instance_double(File) }
    let(:file_list) { [
      {file: file_1, filename: "file_1.jpg"},
      {file: file_2, filename: "file_2.jpg"},
      {file: file_3, filename: "file_3.jpg"}
    ] }

    before do
      allow(file_1).to receive(:size).and_return(1000)
      allow(file_2).to receive(:size).and_return(1000)
      allow(file_3).to receive(:size).and_return(1000)
    end

    it "calls the Zendesk API to get the ticket and add the comment with uploads" do
      service.append_multiple_files_to_ticket(
        ticket_id: 1141,
        file_list: file_list,
        comment: "hey",
        fields: { "314324132" => "custom_field_value" }
      )
      expect(fake_zendesk_ticket).to have_received(:comment=).with({ body: "hey" })
      expect(fake_zendesk_ticket).to have_received(:fields=).with({ "314324132" => "custom_field_value" })
      expect(fake_zendesk_comment.uploads).to include({file: file_1, filename: "file_1.jpg"})
      expect(fake_zendesk_comment.uploads).to include({file: file_2, filename: "file_2.jpg"})
      expect(fake_zendesk_comment.uploads).to include({file: file_3, filename: "file_3.jpg"})
      expect(fake_zendesk_ticket).to have_received(:save!)
    end

    context "when the file is not a valid size" do
      before do
        allow(file_1).to receive(:size).and_return(100000000)
        allow(file_3).to receive(:size).and_return(0)
      end

      it "does not append the file" do
        service.append_multiple_files_to_ticket(
          ticket_id: 1141,
          file_list: file_list,
          comment: "hey",
          fields: { "314324132" => "custom_field_value" }
        )
        expect(fake_zendesk_comment.uploads).not_to include({file: file_1, filename: "file_1.jpg"})
        expect(fake_zendesk_comment.uploads).to include({file: file_2, filename: "file_2.jpg"})
        expect(fake_zendesk_comment.uploads).not_to include({file: file_3, filename: "file_3.jpg"})
        expect(fake_zendesk_ticket).to have_received(:save!)
      end

      it "adds an oversize file message to the comment" do
        service.append_multiple_files_to_ticket(
          ticket_id: 1141,
          file_list: file_list,
          comment: "hey",
          fields: { "314324132" => "custom_field_value" }
        )
        expect(fake_zendesk_comment_body).to have_received(:concat).with("\n\nThe file file_1.jpg could not be uploaded because it exceeds the maximum size of 20MB.")
        expect(fake_zendesk_comment_body).to have_received(:concat).with("\n\nThe file file_3.jpg could not be uploaded because it is empty.")
        expect(fake_zendesk_ticket).to have_received(:save!)
      end
    end
  end

  describe "#append_comment_to_ticket" do
    it "calls the Zendesk API to get the ticket and add the comment" do
      service.append_comment_to_ticket(
        ticket_id: 1141,
        comment: "hey this is a comment",
        fields: { "314324132" => "custom_field_value" },
        tags: ["some", "tags"],
      )

      expect(fake_zendesk_ticket).to have_received(:comment=).with({ body: "hey this is a comment", public: false })
      expect(fake_zendesk_ticket).to have_received(:fields=).with({ "314324132" => "custom_field_value" })
      expect(fake_zendesk_ticket).to have_received(:tags=).with(["old_tag", "some", "tags"])
      expect(fake_zendesk_ticket).to have_received(:save!)
    end
  end

  describe "#get_ticket" do
    it "calls the Zendesk API to get the details for a given ticket id" do
      service.get_ticket(ticket_id: 1141)

      expect(ZendeskAPI::Ticket).to have_received(:find).with(fake_zendesk_client, id: 1141)
    end
  end

  describe "#get_ticket!" do
    before do
      allow(ZendeskAPI::Ticket).to receive(:find).and_return(nil)
    end
    it "raises a MissingTicketError if a ticket is not found" do
      expect {
        service.get_ticket!(1234)
      }.to raise_error(ZendeskServiceHelper::MissingTicketError)
    end
  end

  describe "when the service is for the UWTSA Zendesk instance" do
    let(:service) do
      class SampleService
        include ZendeskServiceHelper

        def instance
          UwtsaZendeskInstance
        end
      end

      SampleService.new
    end

    describe "#append_multiple_files_to_ticket" do
      let(:file_1) { instance_double(File) }
      let(:file_2) { instance_double(File) }
      let(:file_3) { instance_double(File) }
      let(:file_list) { [
        {file: file_1, filename: "file_1.jpg"},
        {file: file_2, filename: "file_2.jpg"},
        {file: file_3, filename: "file_3.jpg"}
      ] }

      before do
        allow(file_1).to receive(:size).and_return(8000000)
        allow(file_2).to receive(:size).and_return(1000)
        allow(file_3).to receive(:size).and_return(1000)
      end

      it "sets the maximum file size to 7MB" do
        service.append_multiple_files_to_ticket(
          ticket_id: 1141,
          file_list: file_list,
          comment: "hey",
          fields: { "314324132" => "custom_field_value" }
        )
        expect(fake_zendesk_comment.uploads).not_to include({file: file_1, filename: "file_1.jpg"})
        expect(fake_zendesk_comment.uploads).to include({file: file_2, filename: "file_2.jpg"})
        expect(fake_zendesk_comment.uploads).to include({file: file_3, filename: "file_3.jpg"})
        expect(fake_zendesk_comment_body).to have_received(:concat).with("\n\nThe file file_1.jpg could not be uploaded because it exceeds the maximum size of 7MB.")
        expect(fake_zendesk_ticket).to have_received(:save!)
      end
    end
  end

  describe "#qualify_user_name" do
    let(:name) { "Some Name" }

    it "appends a qualifier in staging, demo environment" do
      qualified_environments.each do |e|
        with_environment(e) do
          expect(service.qualify_user_name(name)).to eq("#{name} (Fake User)")
        end
      end
    end

    it "doesn't append a qualifier in test, production" do
      unqualified_environments.each do |e|
        with_environment(e) do
          expect(service.qualify_user_name(name)).to eq(name)
        end
      end
    end
  end

  describe "#zendesk_timezone" do
    it "converts iana timezone to Zendesk accepted timezones" do
      expect(service.zendesk_timezone("America/Los_Angeles")).to eq("Pacific Time (US & Canada)")
    end

    it "returns nil when timezone is not found" do
      expect(service.zendesk_timezone("Antarctica/Casey")).to eq(nil)
    end

    it "returns nil when timezone is nil" do
      expect(service.zendesk_timezone(nil)).to eq(nil)
    end
  end

  describe "#test_ticket_tags" do
    context "in a production environment" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it "has no test-related tag" do
        expect(service.test_ticket_tags).to eq([])
      end
    end

    context "in a non-production environment" do
      it "tags the new ticket as test_ticket" do
        expect(service.test_ticket_tags).to eq(["test_ticket"])
      end
    end
  end
end
