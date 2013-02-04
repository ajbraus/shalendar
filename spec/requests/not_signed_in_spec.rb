require 'spec_helper'

describe "Without loging in" do

  let(:private_event) { FactoryGirl.create(:event, :user => user, 
                          :chronic_starts_at => "#{Time.now + 1.day}", 
                          :ends_at => "#{Time.now + 1.day + 2.hours}") }
  let(:city) { FactoryGirl.create(:city)}
  let(:user) { FactoryGirl.create(:user, :city => city) }
  let(:venue) { FactoryGirl.create(:user, :vendor => true, :city => city) }
  let(:public_event) { FactoryGirl.create(:event, :user_id => venue.id,
                     :city => city,
                     :chronic_starts_at => "#{Time.now + 1.day}", 
                     :ends_at => "#{Time.now + 1.day + 2.hours}",
                     :one_time => 't',
                     :title => "Public Event") }

  before(:all) { 30.times { FactoryGirl.create(:user) } }
  after(:all)  { User.delete_all }

  after(:each) { Event.delete_all }

  describe "home page not signed in" do
    before do 
      visit "/"
    end
    it "should have slogan" do
      page.should have_content("hoos.in is an online social calendar")
    end
    it "should have the public event" do
      page.should have_content("Public Event")
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
      page.should have_content("Public Event")
    end
    it "should not have the private event" do
      page.should_not have_content("Test Event")
    end
    it "should have pitch" do 
      page.should have_content("hoos.in is an online social calendar")
    end
  end

  describe "Event#Show" do
    before do
      @event = Factory(:event, :user => user, 
                       :chronic_starts_at => "#{Time.now + 1.day}", 
                       :ends_at => "#{Time.now + 1.day + 2.hours}",)
      visit event_path(@event)
    end 
    it "should have the content Date Tomorrow" do
      page.should have_content((Time.now + 1.day).strftime('%A'))
    end
    it "should have pitch" do 
      page.should have_content("hoos.in is an online social calendar")
    end
  end
end


