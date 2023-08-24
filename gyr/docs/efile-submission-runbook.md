# EfileSubmission runbook

Date: 2021-08-02

Authors: Asheesh Laroia, Shannon Byrne, Travis Grathwell

## Purpose
Engineers might have to handle EfileSubmission records during on-call.
This [runbook](https://en.wikipedia.org/wiki/Runbook) is a guide on how to do that.

## Typical operation

An EfileSubmission record is created during intake when clients have finished submitting the information needed to submit an Advance CTC return.

The EfileSubmission has a state machine attached (EfileSubmissionStateMachine) to it. The standard flow is:

- A record is created as `:new`.
- When it is transitioned to `:preparing`, we create a BundleSubmissionJob and update the tax return status for Hub users. BundleSubmissionJob validates the client's address, generates a 1040 PDF for the client and Hub users to see, and creates a submission ZIP file. It transitions the EfileSubmission to `:queued`.
- When it is transitioned to `:queued`, we create a SendSubmissionJob. This launches gyr-efiler to send the submission ZIP file to the IRS. This sets the state to `:transmitted`.
- Over time, a cron job will run that polls the IRS for status of transmitted submissions. It launches gyr-efiler with the IRS submission IDs. When the IRS responds with the status, the cron job marks the EfileSubmission as `:accepted` or `:rejected` and updates the TaxReturn status.

An EfileSubmission can be resubmitted in the dashboard. This will transition the state to `:resubmitted`. In the case that it was never transmitted to the IRS, we immediately transition from `:resubmitted` to `:preparing`, i.e., we try again to prepare the same submission. This will not send an email to the client; emails are only sent when a `:new` EfileSubmission transitions to `:preparing`. In the case that we have already transmitted the submission to the IRS, that IRS ID cannot be used again, so we create a new EfileSubmission object and keep the original one as `:resubmitted`. This is implemented in the state machine.

## Manual interventions in e.g. rails console

Try to always use `transition_to!(...)` to transition an EfileSubmission's state, rather than launching delayed jobs directly.

Get the current state with `EfileSubmission#current_state`.

## When a submission is `:failed`

You can see all submissions, including failed ones, in the e-file dashboard at /en/hub/efile ([dev](http://localhost:3000/en/hub/efile), [demo](https://demo.getyourrefund.org/en/hub/efile), [prod](https://www.getyourrefund.org/en/hub/efile)). While there is no way in the UI to filter right now, the dashboard supports a `?status={statusValue}` param to filter down to a particular status; /en/hub/efile?status=rejected will filter to rejected state. Only one status at a time is supported at the moment.

We transition the submission to `:failed` when something goes wrong. Depending on the situation, it should be handled by engineers or by client support. The state machine ensures that when the EfileSubmission is `:failed`, we change the tax return status to `:file_needs_review` aka "Needs review" in the Hub.

When client support handles issues, typically they either edit the client's data directly in the Hub if the next step is clear, or alternatively they get in touch with the client to resolve the issue. Client support can mark the e-file submission as "Cancelled" on the dashboard. This may be appropriate if the client has asked us not to refile, or if the resolution to fix it is out of the bounds of the types of cases we handle, etc. This will also transition the associated Tax Return object to status of "Not Filing" due to code in the state machine.

When a crash occurs during a job, we tend to raise an exception so we can see in Sentry what went wrong. We also set the EfileSubmission status to `:failed`. When you see a crash in Sentry, you need to determine if a code change is required. If no code change is required, you can resubmit the return the same way client support does.

If a code change is required, fix the code, then resubmit once the code change is deployed.

## Disabling new submissions temporarily

You can set the HOLD_OFF_NEW_EFILE_SUBMISSIONS environment variable to prevent any EfileSubmission from transitioning to the :preparing state.

Whenever we feel like submitting things again, after the environment variable is removed, you should transition everything that was stuck in 'new' to 'preparing':

`EfileSubmission.in_state(:new).each { |efile_submission| efile_submission.transition_to!(:preparing) }`

## References
* The Child Tax Credit is defined in [IRS Revenue Procedure 2021-4.](https://www.irs.gov/pub/irs-drop/rp-21-24.pdf)
