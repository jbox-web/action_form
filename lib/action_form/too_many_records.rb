# frozen_string_literal: true

module ActionForm
  # Raised when a collection sub-form receives more records than its *records:* option
  # allows for a not-yet-persisted parent. Dynamically added rows (timestamp-keyed, as
  # produced by *link_to_add_association*) are not counted against the limit.
  class TooManyRecords < StandardError
  end
end
