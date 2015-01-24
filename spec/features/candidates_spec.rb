require 'rails_helper'

feature "User searches", :type => :feature do
  scenario 'they make search with postcode' do
    visit '/'

    fill_in 'q', with: 'N15 6RH'
    click_button 'Search'

    # could be better test
    expect(page).to have_css '.candidate-name', 'David Lammy'
  end
# add scenario: wrong postcode
# add scenario: empty search
# add scenario: ...
end
