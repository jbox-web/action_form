# frozen_string_literal: true

require 'spec_helper'

# Coverage for base.rb:97-111: when the root model passes validation but fails to persist,
# #save wraps the write in a transaction, rolls it back (ActiveRecord::Rollback), and
# returns false instead of committing a partial graph.
RSpec.describe('RootSaveRollback') do

  it('returns false and persists nothing when the root model fails to save') do
    form = SaveFailingUserFormFixture.new(SaveFailingUser.new(name: 'Rollback Tester', age: 30, gender: 0))

    # valid? must pass so we reach the save path (not the early *return false unless valid?*).
    expect(form.valid?).to(be(true))

    expect { expect(form.save).to(be(false)) }.to_not(change(User, :count))
  end

end
