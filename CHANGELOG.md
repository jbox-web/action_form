# CHANGELOG

## Unreleased

* Fix: nested-form attributes were tracked on the shared `ActionForm::Form` class, growing unbounded across instantiations and leaking between unrelated forms; they are now tracked per instance
* Fix: submitting a nested `id` that matches no loaded child record now raises `ActiveRecord::RecordNotFound` instead of `NoMethodError` on nil
* Fix: an all-blank new nested row on a persisted parent is now rejected instead of persisted as an empty record (symmetrical with the not-yet-persisted path)
* Fix: `save` now rolls back the transaction when the root model fails to persist, instead of committing a partial save
* Fix: malformed nested-attributes keys and attributes for an undeclared association now raise a clear `ArgumentError` instead of `NoMethodError` on nil
* Add: `ActionForm::TooManyRecords`, raised when a not-yet-persisted collection receives more sequential rows than its `records:` option allows (dynamically added, timestamp-keyed rows are exempt)
* Add: `respond_to_missing?` so `respond_to?` is consistent with the DSL methods intercepted by `method_missing`
* Docs: fix README DSL examples (use `attribute`, one per attribute — there is no plural `attributes` macro), document the jQuery requirement of `action_form.js`, fix typos
* Client-side: anchor the `add_fields` insertion-template regex to a word boundary and drop a dead variable

## 1.4.0 (2021-01-04)

* Drop support of Ruby 2.4
* Drop support of Rails 5.0
* Drop support of Rails 5.1
* Add support of Ruby 3.0
* Add support of Rails 6.1
* Switch from Travis to Github Actions
* Switch from minitest to RSpec

## 1.3.0 (2020-04-04)

* Add support of Ruby 2.7
* Add support of Rails 6.0
* Add Rubocop gem
* Add binstubs to ease development

This is the last version to support Ruby 2.4
This is the last version to support Rails 5.0 and Rails 5.1

## 1.2.0 (2019-02-19)

* Drop support of Ruby 2.2
* Drop support of Ruby 2.3
* Drop support of Rails 4.2
* Add support of Ruby 2.6
* Switch to Zeitwerk to load gem files

## 1.1.0 (2019-02-18)

* Add support of Ruby 2.5
* Add support of Rails 5.2
* Coding style
* Fix: link supports having block

This is the last version to support Ruby 2.2 and Ruby 2.3
This is the last version to support Rails 4.2

## 1.0.0 (2019-02-18)

First release! Imported from https://github.com/railsgsoc/actionform
