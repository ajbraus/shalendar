require 'spec_helper'

describe "Pages after sign up / sign in" do

  let(:user) { FactoryGirl.create(:user) }

  before(:all) { 30.times { FactoryGirl.create(:user) } }
  after(:all)  { User.delete_all }

  before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
  end

  describe "Home Page" do
    it "should have the content 'Date Today'" do
      page.should have_content("#{Time.now.strftime('%A')}")
    end
  end

  describe "Settings Page" do
    before do
      visit edit_user_registration_path
    end
    it "should have the content 'personal settings'" do
      page.should have_content("Personal Settings")
    end
  end

  describe "Manage Friends Page" do
    before do
      visit manage_friends_path
    end
    it "should have the content 'Friends'" do
      page.should have_content("Friends")
    end
  end
end


