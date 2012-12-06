require 'spec_helper'

describe "Pages after sign up / sign in" do

  let(:city) { FactoryGirl.create(:city)}
  let(:user) { FactoryGirl.create(:user, :city => city) }
  let(:venue) { FactoryGirl.create(:venue, :city => city) }

  before(:all) { 30.times { FactoryGirl.create(:user) } }
  after(:all)  { User.delete_all }

  before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Login"
  end

  after(:each) { Event.delete_all }

  describe "Home Page" do
    before do
      visit root_path
    end
    it "should have the content 'Date Today'" do
      page.should have_content("#{Time.now.strftime('%A')}")
    end
  end

  describe "Settings Page" do
    before do
      visit edit_user_registration_path
    end
    it "should have the content 'personal settings'" do
      page.should have_content("Personal Settings")
    end
  end

  describe "Manage Friends Page" do
    before do
      visit manage_friends_path
    end
    it "should have the content 'Friends'" do
      page.should have_content("Friends")
    end
  end

  describe "Activity page" do 
    before do 
      visit user_path(user)
    end
    it "should have the content 'upcoming ideas'" do
      page.should have_content("Upcoming Ideas")
    end
    it "should have the content 'user name'" do
      page.should have_content("#{user.name}")
    end
  end

  describe "Basic Event#Show" do
    before do
      @event = Factory(:event, :user_id => user.id, 
                       :chronic_starts_at => "Tomorrow at 3pm")
      visit event_path(@event)
    end 
    it "should have the content Date Tomorrow" do
      page.should have_content((Time.now + 1.day).strftime('%A'))
    end
  end

  describe "Video and URL image Event#Show" do
     before do
      @event = Factory(:event, :user_id => user.id, 
                       :chronic_starts_at => "Tomorrow at 3pm",
                       :promo_vid => "http://www.youtube.com/watch?v=62rgESCyB2g&feature=g-vrec",
                       :promo_url => "http://ecx.images-amazon.com/images/I/51d2Qu4RGFL._BO2,204,203,200_PIsitb-sticker-arrow-click,TopRight,35,-76_AA300_SH20_OU01_.jpg")
      visit event_path(@event)
    end 
    it "should have the content Date Tomorrow" do
      page.should have_content((Time.now + 1.day).strftime('%A'))
    end
  end

  describe "Public event#Show" do
    before do 
      @event = Factory(:event, :user_id => user.id, 
                 :chronic_starts_at => "Tomorrow at 3pm",
                 :is_public => true)
      visit event_path(@event)
    end 
    it "should have the content Date Tomorrow" do
      page.should have_content((Time.now + 1.day).strftime('%A'))
    end
  end

end


