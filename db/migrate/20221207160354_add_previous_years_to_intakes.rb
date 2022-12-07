class AddPreviousYearsToIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :needs_help_previous_year_3, :integer
    add_column :intakes, :needs_help_previous_year_2, :integer
    add_column :intakes, :needs_help_previous_year_1, :integer
    add_column :intakes, :needs_help_current_year,:integer
    # it says backtaxes form lacks some attribute; what's your plan for addressing that?
    # i didnt think about that yet...thinking
    # im not sure i underdtand the questions_form going to click into it again
    # im just going to run this migration and maybe it will resolve ?
    # ok! Let's try it!
    # wait - how did you choose the column type?
    # cool, I guess that makes sense! :D OK proceed
    # re running the test
    # for activerecord models (e.g. Intake), the list of attributes is computed by looking at the database for what columns
    # exist, so the approach you took has some merit. :(
    # In the case of 'Form' classes in the vita-min & gcf-backend codebases, they aren't exactly ActiveRecord models,
    # they're something else that sorta works similarly, so this approach doesn't work perfectly.
    # hmm ... ok maybe I will try to understand this form file ..or just google it
    # no googling won't help much b/c this is specific to our code, not a general thing that all Rails users experience
    # then i will search for needs_help_2018 and see if that helps
    # one more idea for you - we haven't yet looked at the BacktaxesForm file in particular, merely QuestionsForm;
    # let's look in that file
  end
end
