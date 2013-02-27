require 'spec_helper'

describe "Pages after sign up / sign in" do

  let(:madison) { FactoryGirl.create(:city) }
  let(:stockholm) { FactoryGirl.create(:city, :name => "Stocholm, Sweden", timezone: "Paris") }

  let(:user) { FactoryGirl.create(:user, :city => madison) }
  let(:other_user) { FactoryGirl.create(:user, :city => madison)}

#make them inmates
    #user.relationships.build(followed_id: other_user.id, status: 1)
    #other_user.relationships.build(followed_id: user.id, status: 1)

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

  before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "log.in"
  end

  after(:each) { Event.delete_all }

  describe "with no inmates" do 
    describe "Home Page" do
      before do
        visit root_path
      end
      it "should display the instructions in the mini_calendar" do
        page.should have_content("mini_calendar_explanation")
      end
      it "should not have content 'Friends Only Idea'" do
        page.should not_have_content("Friends Only Idea")
      end
      it "should not have content 'Regular Test Idea'" do
        page.should not_have_content("Regular Test Idea")
      end
    end
  end

  describe "with inmate ideas and times" do
    before(:each) do
      user.inmate!(other_user)
      visit root_path
    end

    describe "regular idea is visible" do
      it "should have the content 'Regular Test Idea'" do
        page.should have_content("Regular Test Idea")
      end
    end

    describe "friends only idea is not visible" do 
      it "should not have content 'Friends Only Idea'" do
        page.should not_have_content("Friends Only Idea")
      end
    end
  end

  describe "RSVPd friends only event is visible" do
    before do
      @rsvp = Factory(:rsvp, :plan => private_event, :guest => user, :inout => 1)
      visit root_path
    end
    it "should have the content 'Test Event'" do
      page.should have_content("Test Private Event")
    end
  end

  #describe "visiting another city" do
  #before do 

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

  describe "My User#Show page" do 
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

  describe "other_user's User#Show page" do
    before do
      visit user_path(other_user)
    end
    it "should not have the contnet 'upcoming ideas'" do
      page.should_not have_content("Upcoming Ideas")
    end
    it "should have the content 'user name'" do
      page.should have_content("#{other_user.name}")
    end
  end


  describe "Basic Event#Show" do
    before do
      @event = Factory(:event, :user_id => user.id, 
                       :chronic_starts_at => "#{Time.now + 1.day}", 
                       :ends_at => "#{Time.now + 1.day + 2.hours}")
      visit event_path(@event)
    end 
    it "should have the content Date Tomorrow" do
      page.should have_content((Time.now + 1.day).strftime('%A'))
    end
  end

  describe "Video and URL image Event#Show" do
     before do
      @event = Factory(:event, :user_id => user.id, 
                       :chronic_starts_at => "#{Time.now + 1.day}",
                       :ends_at => "#{Time.now + 1.day + 2.hours}",
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
      visit event_path(public_event)
    end 
    it "should have the content Date Tomorrow" do
      page.should have_content((Time.now + 1.day).strftime('%A'))
    end
  end

  describe "friending" do    
    before do
      user.follow!(other_user)
    end

    it "should be friends with other_user" do
      user.should be_following(other_user)
      user.followed_users.should include(other_user)
    end
  end

  describe "removing a friendship" do
    before do
      user.follow!(other_user)
      user.unfollow!(other_user)
    end

    it "should not be friends with other_user" do
      user.should_not be_following(other_user)
      user.followed_users.should_not include(other_user)
    end
  end
  
  # describe "Friending a user" do
  #   before do 
  #     visit manage_friends_path
  #   end

  #   it "should have the Date" do
  #     page.should_not have_content("venue Dashboard")
  #     page.should have_content("#{Time.now.strftime('%A')}")
  #   end
  # end

  # describe "Friending a venue" do

  # end

  # describe "Removing a Friend" do 

  # end

  # describe "removing a venue friend" do
 
  # end

# END OF SPEC

end


