require "rails_helper"

RSpec.describe EmailController, type: :controller do
  context "with a valid POST" do
    let(:headers) do
      <<~HEADERS.strip
        Received: by mx0028p1mdw1.sendgrid.net with SMTP id UvbNeDv2BB Mon, 10 Feb 2020 23:29:37 +0000 (UTC)
        Received: from outbyoip2.pod23.use1.zdsys.com (outbyoip2.pod23.use1.zdsys.com [192.161.149.32]) by mx0028p1mdw1.sendgrid.net (Postfix) with ESMTPS id BA7146467A7 for <zendesk-sms@vitataxhelp.org>; Mon, 10 Feb 2020 23:28:01 +0000 (UTC)
        Received: from zendesk.com (unknown [10.221.28.146]) by outbyoip2.pod23.use1.zdsys.com (Postfix) with ESMTP id 48GhsY2342z3hhT8 for <zendesk-sms@vitataxhelp.org>; Mon, 10 Feb 2020 23:28:01 +0000 (UTC)
        Date: Mon, 10 Feb 2020 23:28:01 +0000
        From: \"Text user: +15552341122 (VITA Tax Help)\" <support@eitc.zendesk.com>
        Reply-To: VITA Tax Help <support+idM7W4K4-OZLY@eitc.zendesk.com>
        To: EITC Zendesk SMS Robot <zendesk-sms@vitataxhelp.org>
        Message-ID: <M7W4K4OZLY_5e41e701f984_4bbecf1c70194_sprut@zendesk.com>
        In-Reply-To: <M7W4K4OZLY@zendesk.com> <M7W4K4OZLY_5e41e57c3dd44_4de40f2099212_sprut@zendesk.com>
        Subject: Incoming SMS
        Mime-Version: 1.0
        Content-Type: multipart/alternative; boundary=\"--==_mimepart_5e41e7013e5cb_4bbecf1c702fc\"; charset=utf-8
        Content-Transfer-Encoding: 7bit
        X-Delivery-Context: event-id-1030766596754
        X-Priority: 3
        Auto-Submitted: auto-generated
        X-Auto-Response-Suppress: All
        X-Mailer: Zendesk Mailer
        X-Zendesk-From-Account-Id: 4ca1477
        X-Zendesk-Message-Id: <M7W4K4OZLY_5e41e701f984_4bbecf1c70194_sprut@zendesk.com>
      HEADERS
    end
    let(:html) do
      "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n<html>\n<head>\n  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n  <style type=\"text/css\">\n    table td {\n      border-collapse: collapse;\n    }\n    body[dir=rtl] .directional_text_wrapper { direction: rtl; unicode-bidi: embed; }\n\n  </style>\n</head>\n<body lang='en-us' style=\"width: 100%!important; margin: 0; padding: 0;\">\n  <div style=\"padding: 10px; line-height: 1.5; font-family: 'Lucida Grande',Verdana,Arial,sans-serif; font-size: 12px; color:#444444;\">\n    <div style=\"color: #b5b5b5;\">##- Please type your reply above this line -##</div>\n    <p>phone: +15552341122<br />ticket_id: 103</p><p>sms_test heyo!</p>\n  </div>\n  <div style=\"padding: 10px; line-height: 1.5; font-family: 'Lucida Grande',Verdana,Arial,sans-serif; font-size: 12px; color: #aaaaaa; margin: 10px 0 14px 0; padding-top: 10px; border-top: 1px solid #eeeeee;\">\n          <!-- agent footer -->\n      <p style=\"font-family: Helvetica,Arial,sans-serif; margin-bottom: 15px; font-size: 80%; color:gray;\">\n        You are an agent. Add a comment by replying to this email or <strong><a href=\"https://eitc.zendesk.com/agent/tickets/103\" target=\"_new\">view ticket in Zendesk Support</a></strong>.\n      </p>\n      <table cellpadding=\"1\" cellspacing=\"0\" border=\"0\" role=\"presentation\">\n        <tr><td style='vertical-align:top; font-size:12px; color:#333333; line-height:18px; text-align:right; padding-right:10px; font-family:\"Lucida Grande\",\"Lucida Sans Unicode\",\"Tahoma\",Verdana,sans-serif;' valign='top'><strong>Ticket #</strong></td><td style=\"vertical-align:top; font-size:12px; color:#777; line-height:18px; font-family:'Lucida Grande','Lucida Sans Unicode','Tahoma',Verdana,sans-serif;\" valign=\"top\">103</td></tr>\n        <tr><td style='vertical-align:top; font-size:12px; color:#333333; line-height:18px; text-align:right; padding-right:10px; font-family:\"Lucida Grande\",\"Lucida Sans Unicode\",\"Tahoma\",Verdana,sans-serif;' valign='top'><strong>Status</strong></td><td style=\"vertical-align:top; font-size:12px; color:#777; line-height:18px; font-family:'Lucida Grande','Lucida Sans Unicode','Tahoma',Verdana,sans-serif;\" valign=\"top\">New</td></tr>\n        <tr><td style='vertical-align:top; font-size:12px; color:#333333; line-height:18px; text-align:right; padding-right:10px; font-family:\"Lucida Grande\",\"Lucida Sans Unicode\",\"Tahoma\",Verdana,sans-serif;' valign='top'><strong>Requester</strong></td><td style=\"vertical-align:top; font-size:12px; color:#777; line-height:18px; font-family:'Lucida Grande','Lucida Sans Unicode','Tahoma',Verdana,sans-serif;\" valign=\"top\">Text user: +15552341122</td></tr>\n        <tr><td style='vertical-align:top; font-size:12px; color:#333333; line-height:18px; text-align:right; padding-right:10px; font-family:\"Lucida Grande\",\"Lucida Sans Unicode\",\"Tahoma\",Verdana,sans-serif;' valign='top'><strong>CCs</strong></td><td style=\"vertical-align:top; font-size:12px; color:#777; line-height:18px; font-family:'Lucida Grande','Lucida Sans Unicode','Tahoma',Verdana,sans-serif;\" valign=\"top\">-</td></tr>\n        <tr><td style='vertical-align:top; font-size:12px; color:#333333; line-height:18px; text-align:right; padding-right:10px; font-family:\"Lucida Grande\",\"Lucida Sans Unicode\",\"Tahoma\",Verdana,sans-serif;' valign='top'><strong>Followers</strong></td><td style=\"vertical-align:top; font-size:12px; color:#777; line-height:18px; font-family:'Lucida Grande','Lucida Sans Unicode','Tahoma',Verdana,sans-serif;\" valign=\"top\">-</td></tr>\n        <tr><td class='group_name'style='vertical-align:top; font-size:12px; color:#333333; line-height:18px; text-align:right; padding-right:10px; font-family:\"Lucida Grande\",\"Lucida Sans Unicode\",\"Tahoma\",Verdana,sans-serif;' valign='top'><strong>Group</strong></td><td style=\"vertical-align:top; font-size:12px; color:#777; line-height:18px; font-family:'Lucida Grande','Lucida Sans Unicode','Tahoma',Verdana,sans-serif;\" valign=\"top\">-</td></tr>\n        <tr><td style='vertical-align:top; font-size:12px; color:#333333; line-height:18px; text-align:right; padding-right:10px; font-family:\"Lucida Grande\",\"Lucida Sans Unicode\",\"Tahoma\",Verdana,sans-serif;' valign='top'><strong>Assignee</strong></td><td style=\"vertical-align:top; font-size:12px; color:#777; line-height:18px; font-family:'Lucida Grande','Lucida Sans Unicode','Tahoma',Verdana,sans-serif;\" valign=\"top\">-</td></tr>\n        <tr><td style='vertical-align:top; font-size:12px; color:#333333; line-height:18px; text-align:right; padding-right:10px; font-family:\"Lucida Grande\",\"Lucida Sans Unicode\",\"Tahoma\",Verdana,sans-serif;' valign='top'><strong>Priority</strong></td><td style=\"vertical-align:top; font-size:12px; color:#777; line-height:18px; font-family:'Lucida Grande','Lucida Sans Unicode','Tahoma',Verdana,sans-serif;\" valign=\"top\">-</td></tr>\n        <tr><td style='vertical-align:top; font-size:12px; color:#333333; line-height:18px; text-align:right; padding-right:10px; font-family:\"Lucida Grande\",\"Lucida Sans Unicode\",\"Tahoma\",Verdana,sans-serif;' valign='top'><strong>Type</strong></td><td style=\"vertical-align:top; font-size:12px; color:#777; line-height:18px; font-family:'Lucida Grande','Lucida Sans Unicode','Tahoma',Verdana,sans-serif;\" valign=\"top\">Incident</td></tr>\n        <tr><td style='vertical-align:top; font-size:12px; color:#333333; line-height:18px; text-align:right; padding-right:10px; font-family:\"Lucida Grande\",\"Lucida Sans Unicode\",\"Tahoma\",Verdana,sans-serif;' valign='top'><strong>Channel</strong></td><td style=\"vertical-align:top; font-size:12px; color:#777; line-height:18px; font-family:'Lucida Grande','Lucida Sans Unicode','Tahoma',Verdana,sans-serif;\" valign=\"top\">By SMS</td></tr>\n      </table>\n      <p>&nbsp;</p>\nThis email is a service from Code for America. Delivered by <a href=\"https://www.zendesk.com/support/?utm_campaign=text&amp;utm_content=Code+for+America&amp;utm_medium=poweredbyzendesk&amp;utm_source=email-notification\" style=\"color: black;\" target=\"_blank\">Zendesk</a> | <a href=\"https://www.zendesk.com/company/customers-partners/privacy-policy\" style=\"color: black;\" target=\"_blank\"> Privacy Policy </a>\n  </div>\n<span style='color:#FFFFFF' aria-hidden='true'>[M7W4K4-OZLY]</span><span style='color:#FFFFFF' aria-hidden='true'>Ticket-Id:103</span><span style='color:#FFFFFF' aria-hidden='true'>Account-Subdomain:eitc</span><div itemscope itemtype=\"http://schema.org/EmailMessage\" style=\"display:none\">  <div itemprop=\"action\" itemscope itemtype=\"http://schema.org/ViewAction\">    <link itemprop=\"url\" href=\"https://eitc.zendesk.com/agent/tickets/103\" />    <meta itemprop=\"name\" content=\"View ticket\"/>  </div></div></body>\n</html>\n"
    end
    let(:text) do
      "##- Please type your reply above this line -##\n\n〒\nphone: +15552341122\nticket_id: 103\nbody: sms_test heyo!\nsome other stuff on a new line\n〶\n\n--------------------------------\nThis email is a service from Code for America.\n\n\n\n\n\n\n\n\n\n[M7W4K4-OZLY]"
    end
    let(:spam_report) do
      "Spam detection software, running on the system \"mx0037p1mdw1.sendgrid.net\", has\nidentified this incoming email as possible spam.  The original message\nhas been attached to this so you can view it (if it isn't spam) or label\nsimilar future email.  If you have any questions, see\n@@CONTACT_ADDRESS@@ for details.\n\nContent preview:  ##- Please type your reply above this line -## phone: +15552341122\n   ticket_id: 103 sms_test heyo! [...] \n\nContent analysis details:   (0.0 points, 5.0 required)\n\n pts rule name              description\n---- ---------------------- --------------------------------------------------\n 0.0 HTML_MESSAGE           BODY: HTML included in message\n 0.0 T_MIME_NO_TEXT         No text body parts\n\n"
    end
    let(:to_email) { "zendesk-sms@vitataxhelp.org" }
    let(:from) { "\"Text user: +15552341122 (VITA Tax Help)\" <#{from_email}>" }
    let(:to) { "EITC Zendesk SMS Robot <#{to_email}>" }
    let(:from_email) { "support@eitc.zendesk.com" }
    let(:subject) { "Incoming SMS" }
    let(:params) do
      {
          "headers" => headers,
          "dkim" => "{@zendesk.com : pass}",
          "to" => to,
          "html" => html,
          "from" => from,
          "text" => text,
          "sender_ip" => "192.161.149.31",
          "spam_report" => spam_report,
          "envelope" => "{\"to\":[\"#{to_email}\"],\"from\":\"#{from_email}\"}",
          "attachments" => "0",
          "subject" => subject,
          "spam_score" => "0.011",
          "charsets" => "{\"to\":\"UTF-8\",\"html\":\"utf-8\",\"subject\":\"UTF-8\",\"from\":\"UTF-8\",\"text\":\"utf-8\"}",
          "SPF" => "pass",
      }
    end

    context "to the right email address" do
      let(:to_email) { "zendesk-sms@hooks.vitataxhelp.org" }

      it "returns 200 OK" do
        post :create, params: params

        expect(response).to be_ok
      end

      context "when it's from the right sender", active_job: true do
        it "queues a zendesk inbound sms job" do
          post :create, params: params

          expect(ZendeskInboundSmsJob).to have_been_enqueued.with(
            sms_ticket_id: 103,
            phone_number: "15552341122",
            message_body: "sms_test heyo!\nsome other stuff on a new line",
          )
        end

        it "parses the ticket id, phone number, and message body" do
          post :create, params: params

          expect(assigns(:zendesk_ticket_id)).to eq 103
          expect(assigns(:phone_number)).to eq "15552341122"
          expect(assigns(:message_body)).to eq "sms_test heyo!\nsome other stuff on a new line"
        end
      end

      context "when it's from any other type of sender", active_job: true do
        let(:from) { "Another Person not a client" }

        it "does nothing" do
          post :create, params: params

          expect(ZendeskInboundSmsJob).not_to have_been_enqueued
        end
      end
    end

    context "with a random incoming email" do
      let(:to_email) { "whatevs@vitataxhelp.org" }

      it "returns 200 OK" do
        expect do
          post :create, params: params
        end.to raise_error(StandardError)
      end
    end
  end
end