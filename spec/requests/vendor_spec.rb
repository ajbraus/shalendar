require 'spec_helper'

describe "Pages after sign up / sign in" do

	let(:vendor) { FactoryGirl.create(:vendor) }
  let(:user) { FactoryGirl.create(:user) }
  let(:event) { FactoryGirl.create(:event, :user_id => user.id, 
                       :chronic_starts_at => "Tomorrow at 3pm")}
  before(:all) { 30.times { FactoryGirl.create(:user) } }
  after(:all)  { User.delete_all }

  before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: vendor.email
    fill_in "Password", with: vendor.password
    click_button "Sign in"
  end
  
  after(:each) { Event.delete_all }

  describe "Vendor Home Page" do
    it "should have the Date" do
      page.should_not have_content("Vendor Dashboard")
      page.should have_content("#{Time.now.strftime('%A')}")
    end
  end

  describe "Activity page" do
    before do
      visit activity_path 
    end

    it "should have the content 'Upcoming Ideas'" do
      page.should have_content('Upcoming Ideas')
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

  # describe "creating a public event" do
  # end
end
