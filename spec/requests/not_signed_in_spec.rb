require 'spec_helper'

describe "Without loging in" do

  let(:city) { FactoryGirl.create(:city)}
  let(:user) { FactoryGirl.create(:user, :city => city) }

  let(:idea) { FactoryGirl.create(:event, 
                     :user => user,
                     :city => city,
                     :chronic_starts_at => "#{Time.now + 1.day}", 
                     :ends_at => "#{Time.now + 1.day + 2.hours}",
                     :one_time => 't',
                     :title => "Regular Test Idea") }

  let(:one_time) { FactoryGirl.create(:event, 
                     :user => user,
                     :city => city,
                     :chronic_starts_at => "#{Time.now + 1.day}", 
                     :ends_at => "#{Time.now + 1.day + 2.hours}",
                     :one_time => 't',
                     :title => "One Time Idea") }


  let(:friends_only) { FactoryGirl.create(:event, 
                          :user => user, 
                          :city => city,
                          :title => "Friends Only Idea",
                          :chronic_starts_at => "#{Time.now + 1.day}", 
                          :ends_at => "#{Time.now + 1.day + 2.hours}", :friends_only => true) }


  before(:all) { 30.times { FactoryGirl.create(:user) } }
  after(:all)  { User.delete_all }

  describe "home page not signed in" do
    before do 
      visit root_path
    end
    it "should display the slogan" do
      page.should have_content("hoos.in is an online social calendar")
    end
    it "should display the public event" do
      page.should have_content("Regular Test Idea")
    end
    it "should not display the mini_calendar" do
      page.should not_have_selector("mini_calendar")
    end
  end

  describe "City home page" do
    before do 
      visit "/madison"
    end
    it "should have date time" do
      page.should have_content("#{Time.now.strftime("%A")}")
    end
    it "should have the public event" do
      page.should have_content("Regular Test Idea")
    end
    it "should not have the private event" do
      page.should_not have_content("Friends Only Idea")
    end
    it "should have pitch" do 
      page.should have_content("hoos.in is an online social calendar")
    end
    it "should not display the mini_calendar" do
      page.should not_have_selector("mini_calendar")
    end
  end

  describe "Event#Show" do
    before do
      visit event_path(idea)
    end 
    it "should have the content Date Tomorrow" do
      page.should have_content((Time.now + 1.day).strftime('%A'))
    end
    it "should have pitch" do 
      page.should have_content("hoos.in is an online social calendar")
    end
  end

  describe "user#Show" do
    before do
      visit user_path(user)
    end
    it "should have the user's name" do
      page.should have_content("#{user.name}")
    end
  end
end


