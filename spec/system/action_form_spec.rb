require 'spec_helper'

RSpec.describe 'ActionForm' do
  context 'when form is valid' do
    it 'renders html' do
      visit '/projects/new'
      expect(page).to have_content('New project')
      fill_in :project_name, with: 'Project Foo'
      find('[type=submit]').click
      expect(page).to have_content('A project has a name, and an owner')
      expect(page).to have_content('Project Foo')
    end
  end

  context 'when form is invalid' do
    it 'renders errors' do
      visit '/users/new'
      expect(page).to have_content('New user')
      find('[type=submit]').click
      expect(page).to have_content('7 errors prohibited this user from being saved')
    end
  end
end
