## Interaction Tracking for SLA
*Last updated 5/10/2021 by Shannon Byrne*

## Interaction attributes
- last_outgoing_communication_at
- first_unanswered_incoming_interaction_at: The first interaction from a client that _has not been explicitly replied to (email/recorded call/text).
- last_incoming_interaction_at: Latest interaction from a client to us - can include client doc uploads, texts, emails.
- last_outgoing_communication_at: Last user or system initiated communication (phone call, text, email) to client.
- last_internal_or_outgoing_interaction_at: Latest _internal_ (user or system initiated) interaction with client properties. Includes internal notes, touches to tax returns, etc.
- flagged_at: Tied to the manual flagged_at. Sets as flagged when setting first_unanswered_incoming_interaction, clears on explicit outreach to client OR when a user manually toggles flag in UI.

## Known limitations
- An unconnected phone call object counts as an interaction because an attempt was made even if unsuccessful.
- Off-platform communications can only be tracked by resolving needs attention indicator if it is on -- there's currently no way to manually track off-platform calls/texts/emails/CS interactions on intercom to clear first_unanswered_internal_interaction_at. However, leaving a note will bump last_interaction_at and clear needs response indicator.

## “Internal Interactions”: record_internal_interaction
Writes *last_internal_or_outgoing_interaction_at*. (We record it as an interaction, but it doesn't alter flagged_at status for client)
- Vita User uploads a writes a Note
- VITA User uploads a Document

### “Incoming interaction”: record_incoming_interaction
Writes *last_incoming_interaction_at, updated_at*.
Writes *flagged_at* only if it was not already set (we don't want to overwrite the value if they already needed attention!)
Will only change when:
- Client sends us an email
- Client sends us a text message
- Client uploads a document

### “Outgoing interactions”: record_outgoing_interaction
Changes *last_internal_or_outgoing_interaction_at*, clears *flagged_at*, *updated_at* value
- VITA partner sends client an email
- VITA partner sends a text message
- VITA partner initiates a call to the client

### Manually marking as “flagged”
Sets *flagged_at* IF it is not already set.


### Manually flagging
Clears *flagged_at*.


### Calculating SLA Value

See SLABreachService for exact calculations!

As of this writing, we use the business_days gem to exclude Saturdays and Sundays from SLA calculations.

3 business days is the 2021 Tax Season SLA metric. Until May 10 2021, we used the "flagged" indicator to calculate SLA.
As of May 10 2021, we switched to only considering incoming interactions and explicit response to a client to measure SLA.

Unless we call, email, or text the client OR change their status to a non-SLA tracked status (see TaxReturnStatus):

- A client whose first unanswered incoming interaction is on Friday at 10pm will breach on Wednesday at 10pm.
- A client whose first unanswered interaction is set on Monday at 8:30am will breach on Thursday at 8:30am.
