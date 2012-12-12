require 'spec_helper'

describe "Venue" do

  let(:city) { FactoryGirl.create(:city)}
	let(:venue) { FactoryGirl.create(:user, :vendor => true, :city => city) }
  let(:user) { FactoryGirl.create(:user, :city => city) }
  let(:event) { FactoryGirl.create(:event, :user_id => user.id, 
                       :chronic_starts_at => "Tomorrow at 3pm")}
  
  before(:all) { 30.times { FactoryGirl.create(:user) } }
  after(:all)  { User.delete_all }

  before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: venue.email
    fill_in "Password", with: venue.password
    click_button "log.in"
  end
  
  after(:each) { Event.delete_all }

  describe "onboarding" do
    it "should ask for credit card after signing up" do
      page.should have_content("Credit Card")
    end
  end


  describe "visit Home Page" do
    before do 
      visit root_path
    end

    it "should have the Date" do
      page.should_not have_content("Venue Dashboard")
      page.should have_content("#{Time.now.strftime('%A')}")
    end
  end

  describe "visit profile page" do
    before do
      visit user_path(venue) 
    end

    it "should have the content 'Upcoming Ideas'" do
      page.should have_content('Upcoming Ideas')
    end
    it "should have the content 'venue name'" do
      page.should have_content("#{venue.name}")
    end
  end

  describe "trying to join an idea" do
    before do 
      visit event_path(event)
    end

    it "should not have element with content 'Join'" do
      page.should_not have_content("Join")
      page.should have_content("#{(Time.now + 1.day).strftime('%A')}")
    end
  end

  describe "without valid credit card" do
    before do
      venue.sign_in_count = 10
      venue.credit_card_uri = ""
      visit event_path(event)
    end
    it "should show that the venue's credit card data needs to be updated" do
      page.should have_selector ".alert"
    end
  end

  describe "with valid credit card" do
    before do
      venue.sign_in_count = 10
      venue.credit_card_uri = "123"
      visit event_path(event)
    end
    it "should not see this warning" do
      page.should_not have_selector ".alert"
    end
  end


  # describe "creating a public event" do
  # end
end
