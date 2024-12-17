# Test Fixtures (aka "Personas")

## Into to fed return data

This directory holds sample input data for FYST - i.e. the Federal tax return information we import from Direct File to 
use as a starting point for the State tax return.

There are two data formats we import for each filer: XML & JSON
* The XML data is a somewhat redacted version of the accepted return DF submitted to MeF (we only import accepted 
returns)
* The JSON data is supplemental information (added TY 2024) not covered in the XML schema to reduce additional questions 
needed for State filing

### A note on fixture vs persona

Test "fixtures" is a general term referring to _fixed_ files used for testing, and "personas" refers to a specific
combination of XML + JSON data needed to file as a _person_. Personas are a type of test fixture.

In some contexts, "persona" is used to mean something more specific, e.g. only the filers used in ATS testing, vetted 
and owned by programs. Additionally, sometimes it refers to a specific combination of Federal + State details, sometimes
it only means the Federal data (which then has multiple different State-filing paths). To avoid this confusion, when 
talking about personas that were not created by programs it can be better to use the more general term "fixture" (or 
other terms like "sample filer", etc)- but sometimes it can't be helped and the terms are used interchangeably.

## How fixtures are used

### Manual UI/Acceptance testing

Each State has a set of sample filers that cover a variety of tax scenarios. When using FYST in a non-production 
environment, these samples can be selected in the UI using the 
[DirectFileApiResponseSampleService](../../../app/services/state_file/direct_file_api_response_sample_service.rb)
to complete a State return as that filer and test the expected flow for their scenario. Each story that is implemented 
get acceptance tested and needs tests cases that can demonstrate the functionality. 

Some details of the sample returns can be modified using the 
[FederalInfoForm](../../../app/forms/state_file/federal_info_form.rb), but it has substantial limitations.

### Automated testing

Full fixtures are used in some automated tests - but there is not consistency about when a fixture is used versus use 
test setup to configure expected data inputs and outputs. Tests that use fixtures are brittle, especially if the test 
relies on specific amounts to stay the same rather than setting custom inputs for the intended outputs. There are 
benefits in using fixtures in some cases, but too often they are a crutch for speedy test setup.

Many of our features are implemented before we have complete & vetted sample filers to test against, so we have some 
fixtures based on previous samples to cover more scenarios. When migrating to use the imported personas, it became a 
challenge to untangle test coverage from the fake fixtures. Some of those fixtures are now kept in the `test/` 
directory where they can still be used in automation, but they should not be expected to represent valid filers for the 
entire flow. They cover some non-State-specific features (e.g. data import, income flow, error scenarios) and should be
used with caution.

### E-Filer Certification testing (demo environment only)

Our demo environment is hooked up to test endpoints for DF & MeF, which we use to pass our annual certification test 
required to be e-filers. (This is also referred to as ATS testing.) Personas that have a matching federal submission in
the MeF test server are listed here: 
[submission_id_lookup.yml](../../../app/services/state_file/submission_id_lookup.yml). Those are the only personas that
will have a linked federal return to pass MeF validation. Programs does most of the work to create and track these 
scenarios in order to pass testing and ensure compliance with each State's business rules for filing.

