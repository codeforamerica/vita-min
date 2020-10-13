# consolidated trace

referring to the ConsolidatedTraceHelper,
and PT#172616663 with accompanying
pull request [here](https://github.com/codeforamerica/vita-min/pull/208)

## post-discussion TODOs

- remove automagical everything
- default `with_raven_context` to ERROR
- ensure all instances of `with_raven_context` include
  `intake_context`
- configure Sentry (if possible) not to notify below
  a `:level` of warning

## initial outline

1. what problem am i trying to solve?

   - guard against silent failures when
     interacting with Zendesk, leading to
     subsequent errors
   - provide enough context to investigate
     those errors with a minimum of hunting
     and pecking
   - recover from recoverable errors
     automagically
   - done elsewhere: ensure job context
     is included
   - send information both to Sentry _and_
     the Rails log (Kibana)

2. how does this solve that problem?

   - by detecting the conditions where the
     failures occur and providing context
     and retries where possible.
   - context can include anything, but _should_
     at least include the intake ID, and ZD
     ticket ID.

3. technically, how is this accomplished?

   - using Raven (Sentry Ruby API)
     `extra_context` to convey information
   - using ConsolidateTraceHelper (new) to
     do the publishing work and consolidate
     the error tracing facilities
   - using ApplicationJob to recover from
     a MissingTicketError, and ensure a Zendesk
     ticket exists
   - wrapping the internals of the `#perform`
     method of each job `with_raven_context`,
     and including `ensure_zendesk_ticket_on`
     to kick off the prerequisite job

4. how do jobs work?

   - each job is triggered separately w/o
     dependencies at certain points in the
     flow
   - currently, each job after creating a ZD
     ticket depends on that ticket existing
   - if it doesn't exist, the job fails in a
     fiery explosion (and retries 5 times).
