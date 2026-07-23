# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`action_form` is a Rails gem providing an object-oriented alternative to `accepts_nested_attributes_for`. Instead of pushing nested-model logic into Active Record, you describe a form with a small DSL (`ActionForm::Base` subclass) that owns the attributes, validations, and create/update/destroy of a root model and its nested associations in a single `submit`/`save` cycle.

Requires Ruby `>= 3.2` and Rails `>= 7.0`. Autoloaded via Zeitwerk.

## Commands

Use the project binstubs (never `bundle exec`).

- Run the full suite: `bin/rspec`
- Run a single file: `bin/rspec spec/forms/conference_form_spec.rb`
- Run a single example by line: `bin/rspec spec/forms/conference_form_spec.rb:24`
- Lint: `bin/rubocop` (auto-correct: `bin/rubocop -a`)
- Continuous testing (watches lib + spec): `bin/guard`

### Testing across Rails versions

The gem is tested against multiple Rails versions via [appraisal](https://github.com/thoughtbot/appraisal). Matrix defined in `Appraisals`; generated gemfiles live in `gemfiles/` (`rails_7.2`, `rails_8.0`, `rails_8.1`).

- Run the suite for one Rails version: `BUNDLE_GEMFILE=gemfiles/rails_8.0.gemfile bin/rspec`
- Regenerate gemfiles after editing `Appraisals`: `bin/appraisal install`

CI (`.github/workflows/ci.yml`) runs Rubocop once, then the RSpec matrix across Ruby 3.2–4.0 × the three Rails gemfiles.

## Architecture

The library is a small set of collaborating objects under `lib/action_form/`. The core idea: a **form** wraps a **model**, mirrors its Active Record interface enough to be passed to `form_for`, and recursively delegates nested associations to child forms.

- **`ActionForm::Base`** (`base.rb`) — root form, subclassed by user code. Class-level DSL: `attribute` (one call per attribute; delegates getters/setters to the model, `required: true` adds a presence validation), `association` (registers a nested form), `virtual_attribute` (plain accessor). There is no plural `attributes` declaration macro. On `initialize(model)` it walks the registered associations and builds a child `Form`/`FormCollection` for each. `save` validates, then wraps `model.save` in a transaction (rolling back if the root fails to persist) and runs an `after_save` callback that syncs child forms back.

- **`ActionForm::Form`** (`form.rb`) — a single nested `has_one`/`belongs_to`/nested-in-collection form. Built at runtime (not subclassed): the DSL block passed to `association` is `instance_eval`'d in the new instance, so `attribute`/`association`/`validates` are instance-level here (contrast with `Base` where they are class-level). Uses `method_missing` to forward `validates`/`validate` and any method registered in `ActionForm.external_validation_methods` to the class. Enables `autosave` on the reflected association.

- **`ActionForm::FormCollection`** (`form_collection.rb`) — a `has_many` association. Holds an array of `Form` objects (`records:` option controls how many blanks are built for a new parent). `submit` decides per-entry whether to create, update, or mark-for-destruction (`_destroy == '1'`), distinguishing existing records (present `id`) from dynamically-added ones (index beyond current size). For a not-yet-persisted parent it caps the number of sequential rows at the `records:` count, raising `ActionForm::TooManyRecords` (timestamp-keyed dynamic additions are exempt). A submitted `id` matching no loaded child form raises `ActiveRecord::RecordNotFound`.

- **`ActionForm::FormDefinition`** (`form_definition.rb`) — a deferred association declaration captured at class-definition time (`name`, block, options). `to_form` inspects the association macro and instantiates the right runtime object (`Form` for `has_one`/`belongs_to`, `FormCollection` for `has_many`).

- **`ActionForm::FormHelpers`** (`form_helpers.rb`) — shared `submit` and `valid?`, mixed into `Base` and `Form`. `submit` splits params into scalar attributes (written to the model) vs. `*_attributes` keys (routed to the matching child form). `valid?` runs form-level validations **and** model-level validations, then aggregates child-form errors namespaced by association name.

- **`ActionForm::FormModelWrapper`** (`form_model_wrapper.rb`) — a `SimpleDelegator` that makes a form look like an Active Model to the view layer. Delegates most calls to the form but routes AR identity methods (`persisted?`, `to_key`, `==`, …) and `model_name` to the underlying model. Overrides `class` to return `self` so instance-level interception of class calls like `human_attribute_name`/`validators_on` works (the latter drives required-field asterisks in form builders).

- **`ActionForm::ViewHelpers`** (`view_helpers.rb`) — `link_to_add_association` / `link_to_remove_association` cocoon-style helpers. Auto-detects `semantic_fields_for` / `simple_fields_for` / `fields_for`. Included into `ActionView` by the engine (`engine.rb`).

- **`app/assets/javascripts/action_form.js`** — client-side companion for the add/remove links; users require it via `//= require action_form`.

### Rails compatibility shim

`ActionForm.rails_buggy?` (`action_form.rb`) returns true for Rails `>= 7.0.3`. When true, `Base#to_model` returns a `FormModelWrapper` instead of the raw model, working around a Rails behavior change. Touch this only with the version guard in mind.

## Tests

RSpec + a full Rails dummy app under `spec/dummy/` (models, controllers, views, and form classes in `spec/dummy/app/forms/`). The schema is DB-agnostic and loaded from `spec/dummy/db/schema.rb` before each run (`spec/config_rspec.rb`); fixtures live in `spec/fixtures/`. System specs (`spec/system/`) drive a real browser via Capybara + Cuprite (headless Chrome, `spec/config_capybara.rb`). Coverage is emitted by SimpleCov into `coverage/`.

When adding a feature, the usual pattern is: add/adjust a model + form + view in `spec/dummy/`, then a spec under `spec/forms/`, `spec/views/`, or `spec/system/`.
