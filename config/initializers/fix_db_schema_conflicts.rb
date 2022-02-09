# We load `fix-db-schema-conflicts` with `require:false` in `Gemfile`, then require it here.
#
# This allows us to keep its column sorting functionality but skip its built-in Railtie that
# appends behavior to db:schema:dump to run rubocop.

require 'fix_db_schema_conflicts/schema_dumper'
