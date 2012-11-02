require 'spec_helper'

describe "Pages after sign up / sign in" do

  let(:user) { FactoryGirl.create(:user) }
  let(:vendor) { FactoryGirl.create(:vendor) }

  before(:all) { 30.times { FactoryGirl.create(:user) } }
  after(:all)  { User.delete_all }

  describe "Landing Page" do
    before do 
      visit "/"
    end
    it "should have slogan" do
      page.should have_content("Do Great Things With Friends")
    end
  end

  describe "Event#Show" do
    before do
      @event = Factory(:event, :user_id => user.id, :chronic_starts_at => "Tomorrow at 3pm")
      visit "/events/1"
    end 
    it "should have the content Date Tomorrow" do
      page.should have_content((Time.now + 1.day).strftime('%A'))
    end
  end
end


