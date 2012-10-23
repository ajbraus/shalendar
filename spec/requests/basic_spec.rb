require 'spec_helper'

describe "Static pages" do

  describe "Landing Page" do

    before do
      visit root_path
    end

    it "should have the tagline" do
      page.should have_content('Do Great Things With Friends')
    end

  end

  describe "Shalendar Home Page after sign up / sign in" do

    let(:user) { FactoryGirl.create(:user) }

    before(:all) { 30.times { FactoryGirl.create(:user) } }
    after(:all)  { User.delete_all }

    before(:each) do
      sign_in @user
      # visit new_user_session_path
      # fill_in "Email",    with: user.email
      # fill_in "Password", with: user.password
      # click_button "Sign in"
    end

    it "should have the content 'Date Today'" do
      page.should have_content("#{Time.now.strftime('%A')}")
    end
  end
end


