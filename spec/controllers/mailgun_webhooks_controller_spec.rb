require "rails_helper"

RSpec.describe MailgunWebhooksController do
  describe "#create_incoming_email" do
    let(:params) do
      # Mailgun param documentation:
      #   https://documentation.mailgun.com/en/latest/user_manual.html#parsed-messages-parameters
      {
          "Content-Type" => "multipart/mixed; boundary=\"------------020601070403020003080006\"",
          "Date" => "Fri, 26 Apr 2013 11:50:29 -0700",
          "From" => from,
          "In-Reply-To" => "<517AC78B.5060404@mg-demo.getyourrefund-testing.org>",
          "Message-Id" => "<517ACC75.5010709@mg-demo.getyourrefund-testing.org>",
          "Mime-Version" => "1.0",
          "Received" => "from [10.20.76.69] (Unknown [50.56.129.169]) by mxa.mailgun.org with ESMTP id 517acc75.4b341f0-worker2; Fri, 26 Apr 2013 18:50:29 -0000 (UTC)",
          "References" => "<517AC78B.5060404@mg-demo.getyourrefund-testing.org>",
          "Sender" => "bob@mg-demo.getyourrefund-testing.org",
          "Subject" => "Re: Sample POST request",
          "To" => "Alice <alice@mg-demo.getyourrefund-testing.org>",
          "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:17.0) Gecko/20130308 Thunderbird/17.0.4",
          "X-Mailgun-Variables" => "{\"my_var_1\": \"Mailgun Variable #1\", \"my-var-2\": \"awesome\"}",
          "attachment-count" => "0",
          "body-html" => "<html>\n  <head>\n    <meta content=\"text/html; charset=ISO-8859-1\"\n      http-equiv=\"Content-Type\">\n  </head>\n  <body text=\"#000000\" bgcolor=\"#FFFFFF\">\n    <div class=\"moz-cite-prefix\">\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">Hi Alice,</div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\"><br>\n      </div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">This is Bob.<span class=\"Apple-converted-space\">&nbsp;<img\n            alt=\"\" src=\"cid:part1.04060802.06030207@mg-demo.getyourrefund-testing.org\"\n            height=\"15\" width=\"33\"></span></div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\"><br>\n        I also attached a file.<br>\n        <br>\n      </div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">Thanks,</div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">Bob</div>\n      <br>\n      On 04/26/2013 11:29 AM, Alice wrote:<br>\n    </div>\n    <blockquote cite=\"mid:517AC78B.5060404@mg-demo.getyourrefund-testing.org\" type=\"cite\">Hi\n      Bob,\n      <br>\n      <br>\n      This is Alice. How are you doing?\n      <br>\n      <br>\n      Thanks,\n      <br>\n      Alice\n      <br>\n    </blockquote>\n    <br>\n  </body>\n</html>\n",
          "body-plain" => "Hi Alice,\n\nThis is Bob.\n\nI also attached a file.\n\nThanks,\nBob\n\nOn 04/26/2013 11:29 AM, Alice wrote:\n> Hi Bob,\n>\n> This is Alice. How are you doing?\n>\n> Thanks,\n> Alice\n\n",
          "content-id-map" => "{\"<part1.04060802.06030207@mg-demo.getyourrefund-testing.org>\": \"attachment-1\"}",
          "from" => from,
          "message-headers" => "[[\"Received\", \"by luna.mailgun.net with SMTP mgrt 8788212249833; Fri, 26 Apr 2013 18:50:30 +0000\"], [\"Received\", \"from [10.20.76.69] (Unknown [50.56.129.169]) by mxa.mailgun.org with ESMTP id 517acc75.4b341f0-worker2; Fri, 26 Apr 2013 18:50:29 -0000 (UTC)\"], [\"Message-Id\", \"<517ACC75.5010709@mg-demo.getyourrefund-testing.org>\"], [\"Date\", \"Fri, 26 Apr 2013 11:50:29 -0700\"], [\"From\", \"Bob <bob@mg-demo.getyourrefund-testing.org>\"], [\"User-Agent\", \"Mozilla/5.0 (X11; Linux x86_64; rv:17.0) Gecko/20130308 Thunderbird/17.0.4\"], [\"Mime-Version\", \"1.0\"], [\"To\", \"Alice <alice@mg-demo.getyourrefund-testing.org>\"], [\"Subject\", \"Re: Sample POST request\"], [\"References\", \"<517AC78B.5060404@mg-demo.getyourrefund-testing.org>\"], [\"In-Reply-To\", \"<517AC78B.5060404@mg-demo.getyourrefund-testing.org>\"], [\"X-Mailgun-Variables\", \"{\\\"my_var_1\\\": \\\"Mailgun Variable #1\\\", \\\"my-var-2\\\": \\\"awesome\\\"}\"], [\"Content-Type\", \"multipart/mixed; boundary=\\\"------------020601070403020003080006\\\"\"], [\"Sender\", \"bob@mg-demo.getyourrefund-testing.org\"]]",
          "recipient" => "monica@mg-demo.getyourrefund-testing.org",
          "sender" => sender_email,
          "signature" => "t0t411y-3ncypt3ed-51gn4tur3",
          "stripped-html" => "<html><head>\n    <meta content=\"text/html; charset=ISO-8859-1\" http-equiv=\"Content-Type\">\n  </head>\n  <body bgcolor=\"#FFFFFF\" text=\"#000000\">\n    <div class=\"moz-cite-prefix\">\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">Hi Alice,</div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\"><br>\n      </div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">This is Bob.<span class=\"Apple-converted-space\">&#160;<img width=\"33\" alt=\"\" height=\"15\" src=\"cid:part1.04060802.06030207@mg-demo.getyourrefund-testing.org\"></span></div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\"><br>\n        I also attached a file.<br>\n        <br>\n      </div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">Thanks,</div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">Bob</div>\n      <br>\n      On 04/26/2013 11:29 AM, Alice wrote:<br>\n    </div>\n    <br>\n  \n\n</body></html>",
          "stripped-signature" => "Thanks,\nBob",
          "stripped-text" => "Hi Alice,\n\nThis is Bob.\n\nI also attached a file.",
          "subject" => subject,
          "timestamp" => "1599768656",
          "token" => "th15-15-4-t0k3n",
      }
    end
    let(:sender_email) { "bob@example.com" }
    let(:from) { "Bob <#{sender_email}>" }
    let(:subject) { "Re: Update from GetYourRefund" }

    context "without a valid Mailgun POST" do
      before { allow(MailgunService).to receive(:valid_post?).and_return(false) }

      it "returns 403" do
        post :create_incoming_email, params: params

        expect(response.status).to eq 403
      end
    end

    context "with a valid Mailgun POST" do
      before { allow(MailgunService).to receive(:valid_post?).and_return(true) }

      it "returns 200 OK" do
        post :create_incoming_email, params: params

        expect(response).to be_ok
      end

      context "without a matching client" do
        let(:current_time) { DateTime.new(2020, 9, 10) }
        before { allow(DateTime).to receive(:now).and_return(current_time) }

        it "creates a new client and creates a related incoming email" do
          expect do
            post :create_incoming_email, params: params
          end.to change(IncomingEmail, :count).by(1).and change(Client, :count).by(1)

          email = IncomingEmail.last
          client = Client.last
          expect(email.client).to eq client
          expect(client.email_address).to eq sender_email
          expect(email.sender).to eq sender_email
          expect(email.received_at).to eq current_time
          expect(email.subject).to eq subject
          expect(email.from).to eq from
          expect(email.body_plain).to include "Hi Alice,\n\nThis is Bob."
        end
      end

      context "with a matching client" do
        before do
          allow(ClientChannel).to receive(:broadcast_contact_record)
        end

        let!(:client) { create :client, email_address: sender_email }

        it "sends a real-time update to anyone on this client's page", active_job: true do
          post :create_incoming_email, params: params
          expect(ClientChannel).to have_received(:broadcast_contact_record).with(IncomingEmail.last)
        end

        context "without an attachment" do
          it "creates an incoming email attached to the matching client" do
            expect do
              post :create_incoming_email, params: params
            end.to change(IncomingEmail, :count).by(1)

            email = IncomingEmail.last
            expect(email.client).to eq client

            documents = ActiveStorage::Attachment.all
            expect(documents.count).to eq(0)
          end
        end

        context "with attachments" do
          it "stores them on the IncomingEmail" do
            expect do
              post :create_incoming_email, params: params.update({
                "attachment-count": 2,
                "attachment-1" => Rack::Test::UploadedFile.new("spec/fixtures/attachments/document_bundle.pdf", "application/pdf"),
                "attachment-2" => Rack::Test::UploadedFile.new("spec/fixtures/attachments/test-pattern.png", "image/jpeg"),
                "attachment-3" => Rack::Test::UploadedFile.new("spec/fixtures/attachments/test-spreadsheet.xls", "application/vnd.ms-excel"),
                "attachment-4" => Rack::Test::UploadedFile.new("spec/fixtures/attachments/test-pdf.pdf", ""),
              })
            end.to change(ActiveStorage::Attachment, :count).by(4)

            email = IncomingEmail.last
            expect(email.client).to eq client

            documents = ActiveStorage::Attachment.all
            expect(documents.all.pluck(:record_type).uniq).to eq(["IncomingEmail"])
            expect(documents.all.pluck(:record_id).uniq).to eq([email.id])

            expect(documents.first.blob.download).to eq(open("spec/fixtures/attachments/document_bundle.pdf", "rb").read)
            expect(documents.first.blob.content_type).to eq("application/pdf")
            expect(documents.second.blob.download).to eq(open("spec/fixtures/attachments/test-pattern.png", "rb").read)
            expect(documents.second.blob.content_type).to eq("image/jpeg")
            spreadsheet_message = <<~TEXT
              Unusable file with unknown or unsupported file type.
              File name: test-spreadsheet.xls
              File type: application/vnd.ms-excel
            TEXT
            expect(documents.third.blob.download).to eq(spreadsheet_message)
            expect(documents.third.blob.content_type).to eq("text/plain;charset=UTF-8")
            no_file_type_message = <<~TEXT
              Unusable file with unknown or unsupported file type.
              File name: test-pdf.pdf
              File type:
            TEXT
            expect(documents.fourth.blob.download).to eq(no_file_type_message)
            expect(documents.fourth.blob.content_type).to eq("text/plain;charset=UTF-8")
          end
        end
      end

      context "with multiple matching clients" do
        # We have not discussed the best way to handle this scenario
        # This spec is intended to document existing behavior more than
        # prescribe the correct way to handle this.
        let!(:client1) { create :client, email_address: sender_email }
        let!(:client2) { create :client, email_address: sender_email }

        it "creates a new IncomingEmail linked to the first client" do
          expect do
            post :create_incoming_email, params: params
          end.to change(IncomingEmail, :count).by 1

          email = IncomingEmail.last
          expect(email.client).to eq client1
        end
      end
    end
  end
end
