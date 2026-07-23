# frozen_string_literal: true

# A throwaway User backed by the same table whose save always fails *without raising*:
# the before_save callback halts the chain (throw :abort), so #save returns false while
# #valid? still passes. This is the only realistic trigger for the root-save-failure
# rollback branch (base.rb:107) — no DB constraint in the dummy schema produces it.
class SaveFailingUser < User
  self.table_name = 'users'

  before_save { throw :abort }
end
