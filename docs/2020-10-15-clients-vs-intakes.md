# Intakes vs. Clients

**Date:** 2020-10-15  
**Authors:** Sarah Niemeyer & Ben Golder  
**Pivotal Tracker Story:** [#175233012](https://www.pivotaltracker.com/story/show/175233012)

Right now we just have intakes
- We started making clients (out of intakes) by copying information over, but we aren't using the multiple intakes in any way yet.
- intakes and clients basically have the same info.
- we have a thing that searches for the same contact info and whether you reached a stage where you could add docs, and we block you.

## Needs:
- clients *will* submit duplicates against surprising odds and we need to handle that.
  - they may be trying to update information
  - they might hjust be feeling desperate
  - they may just want to hear back and don't know about other ways to contact us.

## Future plans:
- we haven't had any prior authentication for clients, so they couldn't update much directly and couldn't get info about theier case through the website.
- we are now planning to implement client authentication in the future. to authenticate they need
  - control of their contact info (send a taken based link to sms or email)
  - know a sensitive piece of info (last four of SSN or case number)
 - for security it's not great to reveal who has an account
 - we will want to search for duplicates in the background.


 ## Edges cases that happen:
 - two clients sharing the same contact info (likely family members in same household or people working closely with a case worker)
 - clients resubmit with different contact info (so we might not recognize a match easily)

 ## Possible strategies (we will do #2)
 1. intakes are "immutable" snapshots of data submitted and we copy over "latest" or most correct information to a single client record.
     - two tables, same fields (what about foreign keys for docs/dependents)
 2. we stop using intakes, and just have client records that are carefully updated.
     - one table (probably just renamed from "intake" to "client")

 ## Things we'll need for edge cases & duplicates
 - a way to find possible duplicates in the background
 - a way to manually resolve possible duplicates
 - ways to "merge" duplicates
   - take the latest one
   - take the latest one, but don't erase existing data with new empty fields
   - pick one (offer a choice)
   - pick one for each field
   - overwrite but revert a few fields
 - a way for clients to update their information
 - send clients an email/text if receive a duplicate with their info, with calls to action to resolve if necessary
   - (if everything is the same or just new docs) "we let people know that you entered info and added everything to your case)
   - "can you confirm these changes" --> relay to client sign in
   - ask why they are resubmitting, do research to understand resolve ("have you heard back from us?")

 ## Notes:
 - if someone resubmits with same contact info, we don't want to trust changes right away, but afterwards we can send something
   to their contact info to verify and perhaps send them to the login.

 Duplicate submissions
 - someone submits 20 times
   - (hopefully) identify existing possible duplicates in the background
   - (hopefully) have a way for human to review and merge possible duplicates
   - (hopefully) automate merging of duplicates where possible.
