# IRS Name Line 1 Formatting for EFiling
The IRS has specific rules for how NameLine1 needs to be formatted for the Return 1040 Header.

They are outlined on page 189 of https://www.irs.gov/pub/irs-pdf/p4164.pdf

I[CT] make sense of them as the following:

- There is a maximum of 2 <
- First name and middle initial are always concatenated without <.

**Single filers**

- Between a first/middle and the last name add a `<`.
- Between last name and suffix add a `<`.

**Filers with same last name**
- Concatenate the first/middles, building them the same as single filer and concatenate with `&`
- Add `<` then last name then `<` then suffix (so these last two steps are shared with the single filers)

**Filers with different last names**
- Build the single filer name, if no suffix then add `<` between last and `&`, otherwise if there is a suffix, you've reached your 2 `<` limit and so don't add one before the ampersand.
- Concatenate the first/middle/last of the spouse without special formatting.

This logic is used to implement `SubmissionBuilder::FormattingMethods#name_line_1_type`

There is also logic to truncate lines > 35 which is outlined on page 189 of https://www.irs.gov/pub/irs-pdf/p4164.pdf

Truncate components of the line in the following order until <= 35:
- Spouse last
- Primary last
- Remove spouse middle
- Remove primary middle
- Spouse first
- Primary first
