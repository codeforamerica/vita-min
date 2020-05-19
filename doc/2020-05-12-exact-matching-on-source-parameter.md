# Exact Matching: Intake#source to SourceParameter#code

Prior to [this commit: 2168b47d...](https://github.com/codeforamerica/vita-min/commit/2168b47d53b22cead1440f0090d0bc9a33ee778c), if an `Intake` had a :source
parameter, it was partially matched against a list of leading
source codes associated with partners. As of this commit, we will
instead be matching _exactly_.

## Context

([from slack](https://cfa.slack.com/archives/GABJP4D7G/p1589311098069000?thread_ts=1589298887.064600&cid=GABJP4D7G))

(dramatis personae: @bgolder - team lead, @bvandg - developer)

@bvandg: [the thread on sources] ties in neatly with a question we had about source parameters — my understanding is that we want to be able to partially match the beginning of the source parameter and route accordingly, but an exact match isn’t necessary. for example:

- `thc` => Tax Help Colorado
- `thc-south` => Tax Help Colorado

This is fine until we get to RefundDay. Their source parameter is `RefundDay`,
which is a subset of the characters of `RefundDay-C` (Catalyst Miami),
`RefundDay-H` (Hispanic Unity), and RefundDay-B (Branches).

Should a client’s source be `RefundDay-Cocoa`, we have a problem, since it
matches the leading string for both `RefundDay` and `RefundDay-C`. Where to send it?

_(It feels likely that the desire to match rather than do an exact comparison
might’ve been driven by the notion that only once source code string was
possible per partner. That is very close to not being true.)_

So a question and a recommendation: is my understanding correct that we
currently want to match the beginning, and not use an exact match? If so, my
recommendation is that we change to the policy of an exact match only--for the
benefit of RefundDay at least. It also keeps us from having to limit partners
to codes that aren’t subsets of other codes. (For example, if someone wanted a
`goodw` code, this would conflict with `goodwillsr` if we’re doing partial match,
whereas it doesn’t if we’re doing exact match.) If a partner wants multiple
codes, we can easily add them after today without requiring a change to the
code.

Otherwise, we’ll need to institute a limit on sources such that a new source
can’t be a subset of another source, and RefundDay will need to change.

@bgolder: Just going to add some context, we originally assumed that there would
be only one source code per partner, and that it would be unique. The RefundDay
example is one that I was concerned would break things.

The reason for matching the beginning of the source code was so that if a
partner wanted to test multiple outreach campaigns, we can route all those
intakes to them but still get a breakdown for the relative success of each in
our mixpanel metrics (for example: `thc-facebook`, `thc-newsletter`)

It seems like if we want to properly support the RefundDay codes, we would have
to remove the “test multiple outreach campaigns” functionality, and only do
exact matches. Does that sound correct Ben?

@bvandg: it does. Right now we’re finishing up a lift that will include the
ability to add multiple source codes per partner with a change to a data file
rather than a change to code, so we will (this week likely) have the ability for
partners to test multiple outreach campaigns without the partial matches. Can we
go ahead and switch to exact matches? We can run a query against the production
system to ensure we’re not leaving any of the campaigns out when we deploy this.

`Intake.pluck(:source).uniq #perhaps`

@bgolder: yeah, let’s go ahead and do that.
