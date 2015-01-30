require 'rails_helper'

feature "User searches", :type => :feature do
  scenario 'they make search with postcode' do
    visit '/'

    fill_in 'q', with: 'N156RH'
    click_button 'Search'

    # could be better test
    expect(page).to have_css '.candidate-name', 'David Lammy'

    click_link 'Dee Searle'
    expect(page).to have_css '.candidate-name', 'Dee Searle'
  end
# add scenario: wrong postcode
# add scenario: empty search
# add scenario: ...
end
