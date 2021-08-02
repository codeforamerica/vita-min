# EfileSubmission runbook

Date: 2021-08-02

Authors: Asheesh Laroia, Travis Grathwell

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

An EfileSubmission can transition to `:resubmitted` if it submission ZIP never reached the IRS.

## Manual interventions in e.g. rails console

Try to always use `transition_to!(...)` to transition an EfileSubmission's state, rather than launching delayed jobs directly.

Get the current state with `EfileSubmission#current_state`.

## When a submission is `:failed`

You can see all submissions, including failed ones, in the e-file dashboard at /en/hub/efile ([dev](http://localhost:3000/en/hub/efile), [demo](https://demo.getyourrefund.org/en/hub/efile), [prod](https://www.getyourrefund.org/en/hub/efile)).

We transition the submission to `:failed` when something goes wrong. Depending on the situation, it should be handled by engineers or by client support. The state machine ensures that when the EfileSubmission is `:failed`, we change the tax return status to `:file_needs_review` aka "Needs review" in the Hub.

When client support handles issues, typically they either edit the client's data directly in the Hub if the next step is clear, or alternatively they get in touch with the client to resolve the issue. Client support can also decide they don't want to fix the issue and mark the e-file submission as "Cancelled" within the dashboard.

When a crash occurs during a job, we tend to raise an exception so we can see in Sentry what went wrong. We also set the EfileSubmission status to `:failed`. When you see a crash in Sentry, you need to determine if a code change is required. If no code change is required, you can resubmit the return the same way client support does.

If a code change is required, fix the code, then resubmit once the code change is deployed.

## References
* The Child Tax Credit is defined in [IRS Revenue Procedure 2021-4.](https://www.irs.gov/pub/irs-drop/rp-21-24.pdf)
