## Delete Barely Started Intakes
Delete unconsented GYR intakes (intakes that are between the backtaxes and consent page) that were created more than 2 weeks ago with the `DeleteBarelyStartedGyrIntakesJob` in the rails console.

```bigquery
 DeleteBarelyStartedGyrIntakesJob.new.perform
```

This should delete all barely started intakes, their clients and any record associated to their client (which should hopefully only be TaxReturn records) in batches of 1000. 