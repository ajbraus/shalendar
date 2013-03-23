require 'spec_helper'
require 'pry'

describe "Before signing in" do

  let(:city) { FactoryGirl.create(:city)}
  let(:user) { FactoryGirl.create(:user, :city => city) }

  let(:idea) { FactoryGirl.create(:event, 
                     :user => user,
                     :city => city,
                     :one_time => 'f',
                     :title => "Regular Test Idea") }

  let(:one_time) { FactoryGirl.create(:event, 
                     :user => user,
                     :city => city,
                     :starts_at => "#{Time.now + 1.day}", 
                     :ends_at => "#{Time.now + 1.day + 2.hours}",
                     :one_time => 't',
                     :title => "One Time Idea") }

  let(:friends_only) { FactoryGirl.create(:event, 
                          :user => user, 
                          :city => city,
                          :title => "Friends Only Idea",
                          :starts_at => "#{Time.now + 1.day}", 
                          :ends_at => "#{Time.now + 1.day + 2.hours}", :visibility => 1) }
  
  before(:all) { 30.times { FactoryGirl.create(:user) } }
  after(:all)  { User.delete_all }

  describe "home page not signed in" do
    before do 
      visit root_path
    end
    it "should display the pitch" do
      page.should have_selector(".btn-pitch")
    end
    it "should not display the mini_calendar" do
      page.should_not have_selector(".mini_calendar")
    end
  end

  describe "Event#Show" do
    describe "without time" do 
      before do
        visit event_path(idea) 
      end
      it "should display the pitch" do
        page.should have_selector(".btn-pitch")
      end
      it "should have the title" do
        page.should have_content("Regular Test Idea")
      end
    end
    describe "with time" do
      before do
        @time = FactoryGirl.create(:event,
                          parent: idea,
                          city: city,
                          user: user,
                          chronic_starts_at: "#{Time.zone.now + 1.days}", 
                          ends_at: "#{Time.zone.now + 1.day + 2.hours}",
                          duration: 2,
                          address: "my house",
                          title: "Test Time"
                          )
        visit event_path(idea) 
      end

      it "should have the content Date Tomorrow" do
        page.should have_content((Time.now + 1.day).strftime('%A'))
      end
    end
  end

  describe "user#Show" do
    before do
      visit user_path(user)
    end
    it "should display the pitch" do
      page.should have_selector(".btn-pitch")
    end
    it "should have the user's name" do
      page.should have_content("#{user.name}")
    end
  end
end


