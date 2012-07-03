require 'spec_helper'

describe "Static pages" do

  describe "Landing Page" do

    before do
      visit root_path
    end

    it "should have the content 'Shalendar'" do
      page.should have_content('Shalendar')
    end

    it "should have the base title" do
      page.should have_selector('title',
                        text: "Shalendar")
    end

    it "should not have a custom page title" do
      page.should_not have_selector('title', text: '| Home')
    end

  end

  describe "Shalendar Home Page (after sign up / sign in" do

  let(:user) { FactoryGirl.create(:user) }
    before do
      visit new_user_session_path
      fill_in "Email",    with: user.email
      fill_in "Password", with: user.password
      click_button "Sign in"
    end

    it "should have the content 'Shalendar'" do
      page.should have_content('Shalendar')
    end

    it "should have the base title" do
      page.should have_selector('title',
                        text: "Shalendar")
    end

    # it "should have a custom page title" do
    #   page.should have_selector('title', text: '| Home')
    # end

    it "should have a user toolbar with a logout option" do
      page.should have_content('Logout')
    end

  end

  describe "About page" do

    before do
      visit '/about'
    end

    it "should have the content 'About'" do
      page.should have_content('About')
    end

    it "should have the base title" do
      page.should have_selector('title',
                        text: "Shalendar")
    end
    
    it "should have a custom page title" do
      page.should have_selector('title', text: '| About')
    end
  end

  describe "Contact" do

    before do
      visit '/contact'
    end

    it "should have the content 'Contact'" do
      page.should have_content('Contact')
    end

    it "should have the base title" do
      page.should have_selector('title',
                        text: "Shalendar")
    end

    it "should have a custom page title" do
      page.should have_selector('title', text: '| Contact')
    end

  end
end


