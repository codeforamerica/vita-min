# Changing the year

Once a year or so, the team will need to adjust the app to handle the next year's taxes. Three aspects of this are
covered below.

## Configuring the default tax year

To change the default `TaxReturn` year that we create during intake, change `Rails.application.config.default_tax_year`.

This will also change the default tax year for computing primary taxpayer age within Mixpanel analytics.

## Age-based dependent rules

To change the effective tax year for dependent rules, you can replace `yr_2020_*` with `yr_2021_*` in the codebase. 

Each `Dependent` has all the`Dependent::Rules` methods, prefixed by year. For example, `dependent.yr_2021_age`
calls `age` on `Dependent.Rules` with a year of `2021`.

The IRS has rules that depend on the age of a dependent as of the end of a tax year. The Dependent model
does not store a tax year, and it does store a date of birth of a dependent. All age-specific rules are
handled by `Dependent::Rules`. When the `Rules` object is created, it is given a tax year.

This approach allows us to compute dependent eligibility for whatever tax year we want, if we need to.

## Writing new year-independent code

Rely on `Intake#default_tax_return` if possible. This returns the default tax return for an intake, based on
`Rails.application.config.default_tax_year`.

Rely on the `Dependent#yr_2021_*` methods if you need a year-specific computation. If you want to compute
dependent rules based on the default tax year, consider adding a `yr_default_*` to `Dependent`.

If none of that meets your needs, rely on `Rails.application.config.default_tax_year`.

Try not to write new code that hard-codes the current tax year. Make it easy for us to handle the next tax year.
If it's easy, make it easy to handle multiple tax years at once without changing global config.
