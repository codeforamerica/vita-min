require 'rails_helper'

describe MailgunService do
  describe "#valid_post?" do
    let(:params) do
      {
        "Content-Type"  =>  "multipart/mixed; boundary=\"------------020601070403020003080006\"",
        "Date" => "Fri, 26 Apr 2013 11:50:29 -0700",
        "From" => "Bob <bob@mg-demo.getyourrefund-testing.org>",
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
        "attachment-count" => "2",
        "body-html" => "<html>\n  <head>\n    <meta content=\"text/html; charset=ISO-8859-1\"\n      http-equiv=\"Content-Type\">\n  </head>\n  <body text=\"#000000\" bgcolor=\"#FFFFFF\">\n    <div class=\"moz-cite-prefix\">\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">Hi Alice,</div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\"><br>\n      </div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">This is Bob.<span class=\"Apple-converted-space\">&nbsp;<img\n            alt=\"\" src=\"cid:part1.04060802.06030207@mg-demo.getyourrefund-testing.org\"\n            height=\"15\" width=\"33\"></span></div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\"><br>\n        I also attached a file.<br>\n        <br>\n      </div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">Thanks,</div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">Bob</div>\n      <br>\n      On 04/26/2013 11:29 AM, Alice wrote:<br>\n    </div>\n    <blockquote cite=\"mid:517AC78B.5060404@mg-demo.getyourrefund-testing.org\" type=\"cite\">Hi\n      Bob,\n      <br>\n      <br>\n      This is Alice. How are you doing?\n      <br>\n      <br>\n      Thanks,\n      <br>\n      Alice\n      <br>\n    </blockquote>\n    <br>\n  </body>\n</html>\n",
        "body-plain" => "Hi Alice,\n\nThis is Bob.\n\nI also attached a file.\n\nThanks,\nBob\n\nOn 04/26/2013 11:29 AM, Alice wrote:\n> Hi Bob,\n>\n> This is Alice. How are you doing?\n>\n> Thanks,\n> Alice\n\n",
        "content-id-map" => "{\"<part1.04060802.06030207@mg-demo.getyourrefund-testing.org>\": \"attachment-1\"}",
        "from" => "Bob <bob@mg-demo.getyourrefund-testing.org>",
        "message-headers" => "[[\"Received\", \"by luna.mailgun.net with SMTP mgrt 8788212249833; Fri, 26 Apr 2013 18:50:30 +0000\"], [\"Received\", \"from [10.20.76.69] (Unknown [50.56.129.169]) by mxa.mailgun.org with ESMTP id 517acc75.4b341f0-worker2; Fri, 26 Apr 2013 18:50:29 -0000 (UTC)\"], [\"Message-Id\", \"<517ACC75.5010709@mg-demo.getyourrefund-testing.org>\"], [\"Date\", \"Fri, 26 Apr 2013 11:50:29 -0700\"], [\"From\", \"Bob <bob@mg-demo.getyourrefund-testing.org>\"], [\"User-Agent\", \"Mozilla/5.0 (X11; Linux x86_64; rv:17.0) Gecko/20130308 Thunderbird/17.0.4\"], [\"Mime-Version\", \"1.0\"], [\"To\", \"Alice <alice@mg-demo.getyourrefund-testing.org>\"], [\"Subject\", \"Re: Sample POST request\"], [\"References\", \"<517AC78B.5060404@mg-demo.getyourrefund-testing.org>\"], [\"In-Reply-To\", \"<517AC78B.5060404@mg-demo.getyourrefund-testing.org>\"], [\"X-Mailgun-Variables\", \"{\\\"my_var_1\\\": \\\"Mailgun Variable #1\\\", \\\"my-var-2\\\": \\\"awesome\\\"}\"], [\"Content-Type\", \"multipart/mixed; boundary=\\\"------------020601070403020003080006\\\"\"], [\"Sender\", \"bob@mg-demo.getyourrefund-testing.org\"]]",
        "recipient" => "monica@mg-demo.getyourrefund-testing.org",
        "sender" => "chandler@mg-demo.getyourrefund-testing.org",
        "signature" => given_signature,
        "stripped-html" => "<html><head>\n    <meta content=\"text/html; charset=ISO-8859-1\" http-equiv=\"Content-Type\">\n  </head>\n  <body bgcolor=\"#FFFFFF\" text=\"#000000\">\n    <div class=\"moz-cite-prefix\">\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">Hi Alice,</div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\"><br>\n      </div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">This is Bob.<span class=\"Apple-converted-space\">&#160;<img width=\"33\" alt=\"\" height=\"15\" src=\"cid:part1.04060802.06030207@mg-demo.getyourrefund-testing.org\"></span></div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\"><br>\n        I also attached a file.<br>\n        <br>\n      </div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">Thanks,</div>\n      <div style=\"color: rgb(34, 34, 34); font-family: arial,\n        sans-serif; font-size: 12.666666984558105px; font-style: normal;\n        font-variant: normal; font-weight: normal; letter-spacing:\n        normal; line-height: normal; orphans: auto; text-align: start;\n        text-indent: 0px; text-transform: none; white-space: normal;\n        widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;\n        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,\n        255);\">Bob</div>\n      <br>\n      On 04/26/2013 11:29 AM, Alice wrote:<br>\n    </div>\n    <br>\n  \n\n</body></html>",
        "stripped-signature" => "Thanks,\nBob",
        "stripped-text" => "Hi Alice,\n\nThis is Bob.\n\nI also attached a file.",
        "subject" => "Re: Sample POST request",
        "timestamp" => "1599768656",
        "token" => "th15-15-4-t0k3n",
        "attachment-1" => Rack::Test::UploadedFile.new("spec/fixtures/attachments/document_bundle.pdf", "application/pdf"),
        "attachment-2" => Rack::Test::UploadedFile.new("spec/fixtures/attachments/test-pattern.png", "image/png"),
        "controller" => "mailgun_webhooks",
        "action" => "create_incoming_email"
      }
    end
    let(:given_signature) { "t0t411y-3ncypt3ed-51gn4tur3------" }
    let(:computed_hmac_signature) { "pretend-this-is-the-same-as-above" }
    before do
      allow(EnvironmentCredentials).to receive(:dig).with(:mailgun, :webhook_signing_key).and_return("s1gn1ng-k3y")
      allow(OpenSSL::Digest::SHA256).to receive(:new).and_return("SH4256d1g3st")
      allow(OpenSSL::HMAC).to receive(:hexdigest).and_return(computed_hmac_signature)
      allow(ActiveSupport::SecurityUtils).to receive(:fixed_length_secure_compare).and_return(true)
    end

    it "passes the correct information to OpenSSL" do
      result = MailgunService.valid_post?(params)

      expect(OpenSSL::HMAC).to have_received(:hexdigest).with(
        "SH4256d1g3st",
        "s1gn1ng-k3y",
        "1599768656th15-15-4-t0k3n"
      )
      expect(ActiveSupport::SecurityUtils).to have_received(:fixed_length_secure_compare).with(
        given_signature, computed_hmac_signature
      )
      expect(result).to eq true
    end
  end
end
