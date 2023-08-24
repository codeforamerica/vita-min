# Debug feature tests

Add a `binding.pry` into the context of a test that you want to investigate.

Copy the name of the test (relative path) of the test in question, run `rspec` in your terminal with the `CHROME` flag.

For example, I want to run the `clients_searching_sorting_and_filtering_spec` spec:

```bash
# In the root of the vita-min project
CHROME=y rspec spec/features/hub/clients_searching_sorting_and_filtering_spec.rb
```

This will open a Chrome browser to the context that you added your binding. Now you can execute commands in terminal and see them work in the browser.

Here's a [video showing this in action](https://user-images.githubusercontent.com/9101728/119901780-fa4fa080-bf0b-11eb-86d4-a29cb77a8b9f.mp4).
