# Debug feature tests

Add a `binding.pry` into the context of a test that you want to investigate.

Copy the name of the test (relative path) of the test in question, run `rspect` in your terminal with the `CHROME` flag.

For example, I want to run the `clients_searching_sorting_and_filtering_spec` spec:

```bash
# In the root of the vita-min project
CHROME=y rspec ./spec/features/hub/clients_searching_sorting_and_filtering_spec.rb
```

This will open a chrome browser to the context that you added your binding. Now you can execute commands in terminal and see them work in the browser.
