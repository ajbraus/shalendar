require 'spec_helper'

describe "Users" do

  let(:city) { FactoryGirl.create(:city)}
  let(:user) { FactoryGirl.create(:user, :city => city) }
  let(:other_user) { FactoryGirl.create(:user, :city => city)}

  let(:idea) { FactoryGirl.create(:event, 
                     :user => user,
                     :city => city,
                     :one_time => 'f',
                     :title => "Regular Test Idea") }

  before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_on 'log.in'
  end

  describe "joining an idea" do
    before do 
      visit event_path(idea)
      click_on ".interested"
    end

    it "should have let me in" do
      page.should have_selector(".icon-ok")
      page.should_not have_selector('.let_me_in')
    end
    it "should have contente 'Out'" do
      page.should have_content("flake out")
    end
  end

  describe "flaking from an idea" do
    before do 
      user.rsvp_in!(idea)
      visit event_path(idea)
      click_link "(flake out)"
    end

    it "should have 'interesed' button" do
      page.should have_selector('.btn-rsvp')
      page.should_not have_selector('.let_me_in')
    end
    it "should have 'meh' button" do
      page.should have_selector(".btn_stop_viewing")
    end
  end
end