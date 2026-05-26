# Repository Instructions

Follow `rails_way_code_review.md` for Rails code style and review standards.

Before finishing any code change, run the relevant test slice and RuboCop for
the changed Ruby files. Prefer:

```bash
rtk bin/rubocop -A path/to/changed_file.rb
```

Keep controllers thin, put business rules in models/services, follow RESTful
routes, avoid view-heavy logic, and keep imports/idempotent jobs explicit.
