## Datadog monitoring metrics
*Last updated 2/9/2021 by Ben Golder*

### Twilio
- **`twilio.outgoing_text_messages.sent`**— An outgoing message is sent to Twilio
- **`twilio.outgoing_text_messages.updated.status.#{call_status}`**— An outgoing message gets a status update Twilio
- **`twilio.outbound_calls.initiated`**— We initiate a new outbound call
- **`twilio.outbound_calls.connected`**— We connect an outbound call
- **`twilio.outbound_calls.updated.duration`**— We get an update about an outbound call duration (includes duration number)
- **`twilio.outbound_calls.updated.status.#{call_status}`**— We get an update about an outbound call status
- **`twilio.incoming_text_messages.received`**— We receive a new incoming text message from twilio
- **`twilio.incoming_text_messages.client_found`**— We receive a new incoming text message from twilio with one matching client
- **`twilio.incoming_text_messages.client_found_multiple`**— We receive a new incoming text message from twilio with multiple matching clients
- **`twilio.incoming_text_messages.client_not_found`**— We receive a new incoming text message from twilio with no matching clients
  
### Mailgun
- **`mailgun.outgoing_emails.sent`**— An outgoing email is sent to mailgun
- **`mailgun.incoming_emails.received`**— We receive a new incoming email from mailgun
- **`mailgun.incoming_emails.client_found`**— We receive a new incoming email from mailgun with one matching client
- **`mailgun.incoming_emails.client_found_multiple`**— We receive a new incoming email from mailgun with multiple matching clients
- **`mailgun.incoming_emails.client_not_found`**— We receive a new incoming email from mailgun with no matching clients