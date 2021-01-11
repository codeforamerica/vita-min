## Interaction Tracking for SLA
*Last updated 1/11/2021 by Shannon Byrne*

### “Internal Interactions”: record_internal_interation
Writes *last_interaction_at*. (We record it as an interaction, but it doesn't alter attention_needed status for client)

- Vita User uploads a writes a Note
- VITA User uploads a Document

### “Incoming interaction”: record_incoming_interaction
Writes *last_interaction_at, and last_incoming_interaction, updated_at*.
Writes *attention_needed since* only if it was not already set (we don't want to overwrite the value if they already needed attention!)
Will only change 
- Client sends us an email
- Client sends us a text message
- Client uploads a document

### “Outgoing interactions”: record_outgoing_interaction
Changes *last_interaction_at*, clears *attention_needed_since*, *updated_at* value
- VITA partner sends client an email
- VITA partner sends a text message
- VITA partner initiates a call to the client

### Manually marking as “needs attention”
Sets *attention_needed_since* IF it is not already set.


### Manually marking as resolved
Clears *attention_needed_since*.


### Calculating SLA Value

Calculating whether someone is past SLA can be determined using needs_attention_since:

attention_needed_since >= 72.hours.ago

