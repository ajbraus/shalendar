require 'spec_helper'

describe "Pages after sign up / sign in" do

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

  describe "Vendor Home Page" do
    it "should have the Date" do
      page.should_not have_content("Vendor Dashboard")
      page.should have_content("#{Time.now.strftime('%A')}")
    end
  end
end
