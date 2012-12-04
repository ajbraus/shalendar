require 'spec_helper'

describe "Without loging in" do

  let(:user) { FactoryGirl.create(:user) }
  let(:vendor) { FactoryGirl.create(:vendor) }
  let(:private_event) { FactoryGirl.create(:event, :user => user) }

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
      @public_event = Factory(:event, :chronic_starts_at => "Tomorrow at 3pm", :is_public => true, :user => vendor, :title => "Test Public Event")
      visit "/madison"
    end
    it "should have date time" do
      page.should have_content("#{Time.now.strftime("%A")}")
    end
    it "should have the public event" do
      page.should have_content("Test Public Event")
    end
    it "should not have the private event" do
      page.should_not have_content("Test Event")
    end
  end

  describe "Event#Show" do
    before do
      @event = Factory(:event, :user => user, :chronic_starts_at => "Tomorrow at 3pm")
      visit event_path(@event)
    end 
    it "should have the content Date Tomorrow" do
      page.should have_content((Time.now + 1.day).strftime('%A'))
    end
  end
end


