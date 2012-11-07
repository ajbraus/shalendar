require 'spec_helper'

describe "Pages after sign up / sign in" do

	let(:user) { FactoryGirl.create(:user) }
  let(:vendor) { FactoryGirl.create(:vendor) }

  before(:all) { 30.times { FactoryGirl.create(:user) } }
  after(:all)  { User.delete_all }

  before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: vendor.email
    fill_in "Password", with: vendor.password
    click_button "Sign in"
  end
  
  after(:each) { Event.delete_all }

  describe "joining an idea" do
    before do 
      @event = Factory(:event, :user_id => user.id, 
                       :chronic_starts_at => "Tomorrow at 3pm")
      visit event_path(@event)
      click_button "btn-rsvp"
    end

    it "should have element with class 'unrsvp'" do
      page.should_not have_content("Vendor Dashboard")
      page.should have_content("#{Time.now.strftime('%A')}")
    end
  end

  # describe "removing myself from an idea" do

  # end
end