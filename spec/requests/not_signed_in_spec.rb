require 'spec_helper'

describe "Pages after sign up / sign in" do

  let(:city) { FactoryGirl.create(:city)}
  let(:user) { FactoryGirl.create(:user, :city => city) }
  let(:venue) { FactoryGirl.create(:user, :vendor => true, :city => city) }

  before(:all) { 30.times { FactoryGirl.create(:user) } }
  after(:all)  { User.delete_all }

  after(:each) { Event.delete_all }

  describe "Landing Page" do
    before do 
      visit "/"
    end
    it "should have slogan" do
      page.should have_content("Do Great Things With Friends")
    end
  end

  describe "City home page" do
    before do 
      @public_event = Factory(:event, :user_id => venue.id, :chronic_starts_at => "Tomorrow at 3pm", :is_public => true, :title => "Test Public Event")
      visit "/madison"
    end
    it "should have date time" do
      page.should have_content("#{Time.now.strftime("%A")}")
    end
    it "should have public event" do
      page.should have_content("Test Public Event")
    end
  end

  describe "Event#Show" do
    before do
      @event = Factory(:event, :user_id => user.id, :chronic_starts_at => "Tomorrow at 3pm")
      visit event_path(@event)
    end 
    it "should have the content Date Tomorrow" do
      page.should have_content((Time.now + 1.day).strftime('%A'))
    end
  end
end


