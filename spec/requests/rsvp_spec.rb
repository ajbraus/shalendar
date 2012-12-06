require 'spec_helper'

describe "Users" do

  let(:city) { FactoryGirl.create(:city)}
  let(:user) { FactoryGirl.create(:user, :city => city) }
  let(:event) { FactoryGirl.create(:event, :user_id => user.id, :chronic_starts_at => "Tomorrow at 3pm")}

  before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_on "Login"
  end

  describe "joining an idea" do
    before do 
      visit event_path(event)
      click_on "Join"
    end

    it "should have 'Flake Out'" do
      page.should have_selector('.unrsvp_button')
      page.should_not have_selector('.btn-rsvp')
    end
  end

  describe "flaking from an idea" do
    before do 
      user.rsvp!(event)
      visit event_path(event)
      click_on "Flake Out"
    end

    it "should have element 'Join'" do
      page.should have_selector('.btn-rsvp')
      page.should_not have_selector('.unrsvp_button')
    end
  end
end