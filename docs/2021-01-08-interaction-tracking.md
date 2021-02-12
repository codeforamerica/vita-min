## Interaction Tracking for SLA
*Last updated 2/12/2021 by Shannon Byrne*

## Interaction attributes

- first_unanswered_internal_interaction_at: The first interaction from a client that _has not been explicitly replied to (email/recorded call/text).
- last_incoming_interaction_at: Latest interaction from a client to us - can include client doc uploads, texts, emails.
- last_interaction_at: Latest _internal_ (user or system initiated) interaction with client properties. Includes internal notes, touches to tax returns, etc.
- attention_needed_since: Tied to the manual resolve / mark as needs attention button. Sets as needs attention at same time as setting first_unanswered_incoming_interaction, clears on explict outreach to client OR when a user manually unmarks as needs attention in UI.

## Known limitations

- An unconnected phone call object counts as a last_interaction_at because an attempt was made even if unsuccessful.
- Off-platform communications can only be tracked by resolving needs attention indicator if it is on -- there's currently no way to manually track off-platform calls/texts/emails/CS interactions on intercom to clear first_incoming_internal... However, leaving a note will bump last_interaction_at and clear needs response indicator.
#
## “Internal Interactions”: record_internal_interaction
Writes *last_interaction_at*. (We record it as an interaction, but it doesn't alter attention_needed status for client)

- Vita User uploads a writes a Note
- VITA User uploads a Document

### “Incoming interaction”: record_incoming_interaction
Writes *last_incoming_interaction_at, updated_at*.
Writes *attention_needed _since* only if it was not already set (we don't want to overwrite the value if they already needed attention!)
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

See SLABreachService for exact calculations!

As of this writing, we use the business_days gem to exclude Saturdays and Sundays from SLA calculations.

3 business days is the 2021 Tax Season SLA metric -- this means that:

- A client whose needs_response indicator is set on Friday at 10pm will breach on Wednesday at 10pm.
- A client whose needs_response indicator is set on Monday at 8:30am will breach on Thursday at 8:30am.
