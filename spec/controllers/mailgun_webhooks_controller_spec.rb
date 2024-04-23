require "rails_helper"

RSpec.describe MailgunWebhooksController do
  let(:valid_auth_credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials("validuser", "p@sswrd!")
  end

  let(:invalid_auth_credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials("H4x0rD00D", "H4XnU")
  end

  before do
    @test_environment_credentials.merge!(mailgun: {
      basic_auth_name: "validuser",
      basic_auth_password: 'p@sswrd!',
    })
    allow(IntercomService).to receive(:create_message).and_return nil
  end

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
    let(:actual_email) {"bob+test-suffix@example.com"}
    let(:from) { "Bob <#{actual_email}>" }
    let(:subject) { "Re: Update from GetYourRefund" }

    context "without valid HTTP basic auth credentials" do
      before { request.env["HTTP_AUTHORIZATION"] = invalid_auth_credentials }

      it "returns 401 Not Authorized" do
        post :create_incoming_email, params: params

        expect(response.status).to eq 401
      end
    end

    context "with HTTP basic auth credentials", requires_default_vita_partners: true do
      before do
        request.env["HTTP_AUTHORIZATION"] = valid_auth_credentials
        allow(DatadogApi).to receive(:increment)
      end

      it "returns 200 OK" do
        post :create_incoming_email, params: params

        expect(response).to be_ok
      end

      context "without a matching client" do
        let(:current_time) { DateTime.new(2020, 9, 10) }
        before do
          allow(DateTime).to receive(:now).and_return(current_time)
          allow(DatadogApi).to receive(:increment)
          allow(IntercomService).to receive(:create_message)
        end

        context "without a matching archived intake" do
          it "forwards the message to intercom" do
            expect do
              post :create_incoming_email, params: params.merge({ "stripped-text" => "Hi Alice,\n\nThis is Bob." })
            end.to change(IncomingEmail, :count).by(0).and change(Client, :count).by(0)
            expect(IntercomService).to have_received(:create_message).with(
              email_address: actual_email,
              body: "Hi Alice,\n\nThis is Bob.",
              phone_number: nil,
              client: nil,
              has_documents: false
            )
          end
        end

        context 'with an opted-out state-file intake' do
          let(:email) { 'email@test.com' }
          let!(:state_intake) { create :state_file_az_intake, email_address: email, unsubscribed_from_email: true }
          let!(:another_intake) { create :state_file_az_intake, email_address: 'another-email@test.gov', unsubscribed_from_email: true }

          xit 'reopt-in statefile-intake based on email' do
            params['sender'] = email
            post :create_incoming_email, params: params
            state_intake.reload
            expect(state_intake.unsubscribed_from_email).to be_falsey
          end

          xit 'does NOT reopt-in statefile-intake based on a slighlty different email version' do
            params['sender'] = 'email+01@test.com'
            post :create_incoming_email, params: params
            state_intake.reload
            expect(state_intake.unsubscribed_from_email).to be_truthy
          end

          xit 'does NOT reopt-in for state-file intakes without an associated incoming email' do
            params['sender'] = email
            post :create_incoming_email, params: params
            another_intake.reload
            expect(another_intake.unsubscribed_from_email).to be_truthy
          end
        end

        it "sends a metric to Datadog" do
          post :create_incoming_email, params: params

          expect(DatadogApi).to have_received(:increment).with("mailgun.incoming_emails.received")
          expect(DatadogApi).to have_received(:increment).with("mailgun.incoming_emails.client_not_found")
        end
      end

      context "with a matching client" do
        before do
          allow(ClientChannel).to receive(:broadcast_contact_record)
          allow(TransitionNotFilingService).to receive(:run)
        end

        let(:tax_returns) { [(build :gyr_tax_return, :prep_preparing)] }
        let!(:client) do
          create :client,
                 intake: build(:intake, email_address: actual_email),
                 tax_returns: tax_returns
        end
        let!(:archived_intake) { create :archived_2021_ctc_intake, client: client, email_address: actual_email }

        it "sends a real-time update to anyone on this client's page", active_job: true do
          post :create_incoming_email, params: params
          expect(ClientChannel).to have_received(:broadcast_contact_record).with(IncomingEmail.last)
        end

        it "calls the TransitionNotFilingService" do
          post :create_incoming_email, params: params
          expect(TransitionNotFilingService).to have_received(:run).with(client)
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

          it "sends a metric to Datadog" do
            post :create_incoming_email, params: params

            expect(DatadogApi).to have_received(:increment).with("mailgun.incoming_emails.received")
            expect(DatadogApi).to have_received(:increment).with("mailgun.incoming_emails.client_found")
          end
        end

        context "with attachments" do
          it "stores them on the IncomingEmail" do
            expect do
              post :create_incoming_email, params: params.update({
                "attachment-count": 5,
                "attachment-1" => Rack::Test::UploadedFile.new("spec/fixtures/files/document_bundle.pdf", "application/pdf"),
                "attachment-2" => Rack::Test::UploadedFile.new("spec/fixtures/files/test-pattern.png", "image/jpeg"),
                "attachment-3" => Rack::Test::UploadedFile.new("spec/fixtures/files/test-spreadsheet.xls", "application/vnd.ms-excel"),
                "attachment-4" => Rack::Test::UploadedFile.new("spec/fixtures/files/test-pdf.pdf", ""),
                "attachment-5" => Rack::Test::UploadedFile.new("spec/fixtures/files/zero-bytes.jpg", "image/jpeg"),
              })
            end.to change(Document, :count).by(5)

            email = IncomingEmail.last
            expect(email.client).to eq client

            documents = client.documents.order(:id)
            expect(documents.all.pluck(:document_type).uniq).to eq([DocumentTypes::EmailAttachment.key])
            expect(documents.first.contact_record).to eq email
            expect(documents.first.upload.blob.download).to eq(open("spec/fixtures/files/document_bundle.pdf", "rb").read)
            expect(documents.first.upload.blob.content_type).to eq("application/pdf")
            expect(documents.second.upload.blob.download).to eq(open("spec/fixtures/files/test-pattern.png", "rb").read)
            expect(documents.second.upload.blob.content_type).to eq("image/jpeg")
            spreadsheet_message = <<~TEXT
              Unusable file with unknown or unsupported file type.
              File name:'test-spreadsheet.xls'
              File type:'application/vnd.ms-excel'
              File size: 25600 bytes
            TEXT
            expect(documents.third.upload.blob.download).to eq(spreadsheet_message)
            expect(documents.third.upload.blob.content_type).to eq("text/plain;charset=UTF-8")
            expect(documents.third.upload.blob.filename.to_s).to end_with(".txt")
            no_file_type_message = <<~TEXT
              Unusable file with unknown or unsupported file type.
              File name:'test-pdf.pdf'
              File type:''
              File size: 13723 bytes
            TEXT
            expect(documents.fourth.upload.blob.download).to eq(no_file_type_message)
            expect(documents.fourth.upload.blob.content_type).to eq("text/plain;charset=UTF-8")
            empty_file_message = <<~TEXT
              Unusable file with unknown or unsupported file type.
              File name:'zero-bytes.jpg'
              File type:'image/jpeg'
              File size: 0 bytes
            TEXT
            expect(documents.fifth.upload.blob.download).to eq(empty_file_message)
            expect(documents.fifth.upload.blob.content_type).to eq("text/plain;charset=UTF-8")
          end

          it 'excludes files with .mail extensions even if they have supported content_type' do
            expect do
              post :create_incoming_email, params: params.update({
                                                                   "attachment-count": 2,
                                                                   "attachment-1" => Rack::Test::UploadedFile.new("spec/fixtures/files/email-attachment.mail", "image/png"),
                                                                   "attachment-2" => Rack::Test::UploadedFile.new("spec/fixtures/files/test-pattern.png", "image/jpeg"),
                                                                 })
            end.to change(Document, :count).by(1)

            email = IncomingEmail.last
            expect(email.client).to eq client

            documents = client.documents.order(:id)
            expect(documents.all.pluck(:document_type).uniq).to eq([DocumentTypes::EmailAttachment.key])
            expect(documents.first.contact_record).to eq email
            expect(documents.first.upload.blob.download).to eq(open("spec/fixtures/files/test-pattern.png", "rb").read)
            expect(documents.first.upload.blob.content_type).to eq("image/jpeg")
          end

          it 'excludes files that match our logo exactly' do
            expect do

              post :create_incoming_email, params: params.update({
                                                                   "attachment-count": 2,
                                                                   "attachment-1" => Rack::Test::UploadedFile.new("public/images/logo.png", "image/png"),
                                                                   "attachment-2" => Rack::Test::UploadedFile.new(StringIO.new("A" * File.size("public/images/logo.png")), "image/png", original_filename: "image001.png"),
                                                                   "attachment-3" => Rack::Test::UploadedFile.new("spec/fixtures/files/test-pattern.png", "image/png"),
                                                                 })
            end.to change(Document, :count).by(2)

            email = IncomingEmail.last
            expect(email.client).to eq client

            documents = client.documents.order(:id)
            expect(documents.all.pluck(:document_type).uniq).to eq([DocumentTypes::EmailAttachment.key])
            expect(documents.first.contact_record).to eq email
            expect(documents.first.upload.blob.download).to eq("A" * File.size("public/images/logo.png"))
            expect(documents.second.upload.blob.download).to eq(open("spec/fixtures/files/test-pattern.png", "rb").read)
          end
        end

        context "has tax return status in file_accepted, file_mailed or file_not_filing" do
          let!(:tax_returns) { [(build :gyr_tax_return, :file_not_filing), (build :tax_return, :file_accepted, year: 2019)] }

          before do
            AdminToggle.create(name: AdminToggle::FORWARD_MESSAGES_TO_INTERCOM, value: true, user: create(:admin_user))
            allow(IntercomService).to receive(:create_message)
            allow(IntercomService).to receive(:inform_client_of_handoff)
          end

          context "with a body" do
            it "creates intercom message for the client" do
              post :create_incoming_email, params: params

              expect(IntercomService).to have_received(:create_message).with(body: IncomingEmail.last.body, email_address: client.intake.email_address, has_documents: false, phone_number: nil, client: client)
              expect(IntercomService).to have_received(:inform_client_of_handoff).with(send_sms: false, send_email: true, client: client)
            end

            context "and with an attachment" do
              it "tells Intercom there are documents" do
                expect do
                  post :create_incoming_email, params: params.update({
                                                                       "attachment-count": 1,
                                                                       "attachment-1" => Rack::Test::UploadedFile.new("spec/fixtures/files/document_bundle.pdf", "application/pdf"),
                                                                     })
                end.to change(IncomingEmail, :count).by(1).and change(Client, :count).by(0)
                expect(IntercomService).to have_received(:create_message).with(
                  email_address: actual_email,
                  body: "Hi Alice,\n\nThis is Bob.\n\nI also attached a file.\nThanks,\nBob",
                  phone_number: nil,
                  client: client,
                  has_documents: true
                )
              end
            end
          end

          context "without a body or attachments" do
            before do
              allow_any_instance_of(IncomingEmail).to receive(:body).and_return ""
              allow(Sentry).to receive(:capture_message)
              allow(IntercomService).to receive(:create_message)
            end

            it "sends a message to Sentry" do
              post :create_incoming_email, params: params
              expect(Sentry).to have_received(:capture_message).with("IncomingEmail #{IncomingEmail.last.id} does not have a body or any attachments.")
            end

            it "does not create an intercom message for the client" do
              post :create_incoming_email, params: params
              expect(IntercomService).not_to have_received(:create_message)
            end
          end
        end

        context "doesn't have tax return status in file_accepted, file_mailed or file_not_filing" do
          before do
            allow(IntercomService).to receive(:create_message)
          end
          it "does not create an intercom message for the client" do
            post :create_incoming_email, params: params
            expect(IntercomService).not_to have_received(:create_message)
          end
        end

        context "without a body but with a subject" do
          it "stores the email" do
            expect do
              post :create_incoming_email, params: params.except!("body-plain", "body-html", "stripped-text", "stripped-html")
            end.to change(IncomingEmail, :count).by(1)

            email = IncomingEmail.last
            expect(email.client).to eq client
            expect(email.body_plain).to be_nil
            expect(email.body_html).to be_nil
            expect(email.stripped_text).to be_nil
            expect(email.stripped_html).to be_nil
          end
        end

        context "with a matching archived intake only" do
          before do
            client.intake.destroy!
          end

          it "sends an automated message saying that replies are not monitored" do
            expect {
              post :create_incoming_email, params: params
            }.to change(OutgoingEmail, :count).by(1)

            outgoing_email = OutgoingEmail.last
            expect(outgoing_email.subject).to eq("Replies not monitored")
            expect(outgoing_email.body).to eq("Replies not monitored. Write support@test.localhost for assistance. To check on your refund status, go to <a href=\"https://www.irs.gov/refunds\">Where's My Refund?</a> To access your tax record, get <a href=\"https://www.irs.gov/individuals/get-transcript\">your transcript.</a>")
            expect(outgoing_email.client).to eq client
            expect(outgoing_email.user).to eq nil
            expect(outgoing_email.to).to eq archived_intake.email_address
            expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_email)
          end

          it "sends a metric to Datadog" do
            post :create_incoming_email, params: params

            expect(DatadogApi).to have_received(:increment).with("mailgun.outgoing_emails.sent_replies_not_monitored")
          end
        end
      end

      context "with multiple matching clients" do
        let(:intake1) { build :intake, email_address: actual_email }
        let(:intake2) { build :intake, email_address: actual_email }
        let!(:client1) { create :client, intake: intake1 }
        let!(:client2) { create :client, intake: intake2 }

        it "creates a new IncomingEmail linked to both clients" do
          expect do
            post :create_incoming_email, params: params
          end.to change(IncomingEmail.where(client_id: [client1, client2]), :count).by 2
        end

        it "sends a metric to Datadog" do
          post :create_incoming_email, params: params

          expect(DatadogApi).to have_received(:increment).with("mailgun.incoming_emails.received")
          expect(DatadogApi).to have_received(:increment).with("mailgun.incoming_emails.client_found_multiple")
        end

        context "with attachments" do
          it "stores them on each client" do
            expect do
              post :create_incoming_email, params: params.update(
                { "attachment-count": 1, "attachment-1" => Rack::Test::UploadedFile.new("spec/fixtures/files/document_bundle.pdf", "application/pdf"),}
              )
            end.to change(Document, :count).by(2)

            documents = Document.where(client: [client1, client2])
            expect(documents.first.upload.blob.download).to eq(open("spec/fixtures/files/document_bundle.pdf", "rb").read)
            expect(documents.second.upload.blob.download).to eq(open("spec/fixtures/files/document_bundle.pdf", "rb").read)
          end
        end
      end
    end
  end

  describe "#update_outgoing_email_status" do
    let(:message_id) { "DACSsAdVSeGpLid7TN03WA" }
    let(:params) do
      {
          "signature":
              {
                  "timestamp": "1529006854",
                  "token": "a8ce0edb2dd8301dee6c2405235584e45aa91d1e9f979f3de0",
                  "signature": "d2271d12299f6592d9d44cd9d250f0704e4674c30d79d07c47a66f95ce71cf55"
              },
          "event-data":
            {
                  "event": "opened",
                  "timestamp": 1529006854.329574,
                  "message":
                    {
                    "headers":
                      {
                        "message-id": message_id
                      }
                  }
              }
      }
    end

    context "with HTTP basic auth credentials" do
      before do
        request.env["HTTP_AUTHORIZATION"] = valid_auth_credentials
        allow(DatadogApi).to receive(:increment)
      end

      context "when there is a matching outgoing email" do
        let!(:outgoing_email) { create :outgoing_email, message_id: message_id  }

        it "updates it with provided status" do
          post :update_outgoing_email_status, params: params
          expect(outgoing_email.reload.mailgun_status).to eq "opened"
        end
      end

      context "when there is a matching state file notification email" do
        let!(:state_file_notification_email) { create :state_file_notification_email, message_id: message_id}

        it "updates it with provided status" do
          post :update_outgoing_email_status, params: params
          expect(state_file_notification_email.reload.mailgun_status).to eq "opened"
        end
      end

      context "when there is a matching VerificationEmail" do
        let!(:verification_email) { create(:verification_email, mailgun_id: message_id) }
        it "updates the VerificationEmail object with the status" do
          post :update_outgoing_email_status, params: params
          expect(verification_email.reload.mailgun_status).to eq "opened"
        end
      end

      context "when there is a matching OutgoingMessageStatus" do
        let!(:outgoing_message_status) { create(:outgoing_message_status, :email, message_id: message_id) }
        it "updates the record with the status" do
          post :update_outgoing_email_status, params: params
          expect(outgoing_message_status.reload.delivery_status).to eq "opened"
        end
      end

      context "when there is no message with a matching mailgun id" do
        let(:message_id) { "something_not_matching" }
        it "fails gracefully + reports failure to datadog" do
          post :update_outgoing_email_status, params: params
          expect(DatadogApi).to have_received(:increment).with("mailgun.update_outgoing_email_status.email_not_found")

          expect(response).to be_ok
        end
      end
    end
  end
end
