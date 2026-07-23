# frozen_string_literal: true

require 'spec_helper'

# Fixtures: VirtualAttributeFormFixture (root-level) and VirtualNestedFormFixture
# (association-level) live in spec/support.
RSpec.describe('VirtualAttribute') do

  it('exposes a plain read/write accessor on the root form, not delegated to the model') do
    form = VirtualAttributeFormFixture.new(User.new)

    form.password_confirmation = 'secret'

    expect(form.password_confirmation).to(eq('secret'))
  end

  it('exposes a plain read/write accessor on a nested association form') do
    nested = VirtualNestedFormFixture.new(Project.new).owner

    nested.captcha = 'not-a-robot'

    expect(nested.captcha).to(eq('not-a-robot'))
  end

end
