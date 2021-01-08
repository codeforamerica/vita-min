## Interaction Tracking for SLA
*Last updated 1/8/2021 by Shannon Byrne*

### “Internal Interactions”: record_internal_interation
Changes client *updated_at*. (We record that the client was touched, but we don't count it as an interaction for SLA tracking purposes)

- Vita User uploads a writes a Note
- VITA User uploads a Document

### “Incoming interaction”: record_incoming_interaction
Changes *needs_response_since, last_interaction_at, and last_incoming_interaction, updated_at*
- Client sends us an email
- Client sends us a text message
- Client uploads a document

### “Outgoing interactions”: record_outgoing_interaction
Changes *last_interaction_at*, clears *needs_response_since*, *updated_at* value
- VITA partner sends client an email
- VITA partner sends a text message
- VITA partner initiates a call to the client

### Manually marking as “needs attention”
Sets *needs_attention_since* and manually sets *last_incoming_interaction_at*

Feature is intended to capture interactions with the client that occur outside of the application.

### Manually marking as resolved
Clears *needs_attention_since* and manually records an interaction with the client *last_interaction_at*

Feature is intended to capture interactions with the client that occur outside of the application.


### Calculating SLA Value

Calculating whether someone is past SLA can be determined as such:

last_interaction_at == last_incoming_interaction && last_incoming_interaction > 72.hours.ago

If the last_incoming_interaction_at does not match the last_interaction_at value, we're not in danger of going over SLA for them and the value should be nil!

