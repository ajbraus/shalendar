require 'spec_helper'

# save_and_open_page

describe "Home page after sign in" do

  let(:city) { FactoryGirl.create(:city) }
  let(:stockholm) { FactoryGirl.create(:city, :name => "Stockholm, Sweden", timezone: "Paris") }

  let(:user) { FactoryGirl.create(:user, :city => city) }
  let(:other_user) { FactoryGirl.create(:user, :city => city) }

  let(:stockholm_user) { FactoryGirl.create(:user, :city => stockholm) }
  
  let(:madison_idea) { FactoryGirl.create(:event, 
                     :user => user,
                     :city => city,
                     :one_time => 'f',
                     :title => "Madison Test Idea") }

  let(:stockholm_idea) { FactoryGirl.create(:event, 
                     :user => user,
                     :city => stockholm,
                     :one_time => 'f',
                     :title => "Stockholm Test Idea") }

  let(:inmate_idea) { FactoryGirl.create(:event, 
                     :user => other_user,
                     :city => city,
                     :one_time => 'f',
                     :title => "Inmate Test Idea") }

  let(:stockholm_inmate_idea) { FactoryGirl.create(:event, 
                     :user => other_user,
                     :city => stockholm,
                     :one_time => 'f',
                     :title => "Stockholm Inmate Test Idea") }

  let(:one_time) { FactoryGirl.create(:event, 
                     :user => other_user,
                     :city => madison,
                     :starts_at => "#{Time.now + 1.day}", 
                     :ends_at => "#{Time.now + 1.day + 2.hours}",
                     :one_time => 't',
                     :title => "One Time Idea") }

  let(:friends_only) { FactoryGirl.create(:event, 
                          :user => other_user, 
                          :city => city,
                          :one_time => 'f',
                          :friends_only => 't',
                          :title => "Friends Only Idea") }

  before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "log.in"
    user.rsvp_in!(madison_idea) #because creators of ideas need to be rspvd for their ideas
    other_user.rsvp_in!(inmate_idea)
    other_user.rsvp_in!(friends_only)
  end

  #after(:all) { Event.delete_all }

  describe "with no inmates" do 
    before do
      visit root_path
    end
    it "should display the instructions in the mini_calendar" do
      page.should have_selector(".mini_calendar_explanation")
    end
    it "should have content 'Madison Test Idea'" do
      page.should have_content("Madison Test Idea")
    end
    it "should not have content 'Friends Only Idea'" do
      page.should_not have_content("Friends Only Idea")
    end
    it "should not have content 'Inmate Test Idea'" do
      page.should_not have_content("Inmate Test Idea")
    end
    it "should not have content 'Stockholm Test Idea'" do
      page.should_not have_content("Stockholm Test Idea")
    end
    it "should not have content 'Stockholm Inmate Test Idea'" do
      page.should_not have_content("Stockholm Inmate Test Idea")
    end
  end

  describe "with madison inmate" do
    before(:each) do
      user.inmate!(other_user)
      visit root_path
    end
    it "should have the content 'Inmate Test Idea'" do
      page.should have_content("Inmate Test Idea")
    end
    it "should not have content 'Friends Only Idea'" do
      page.should_not have_content("Friends Only Idea")
    end
  end

  describe "home Page with stockholm inmate" do
    before(:each) do 
      user.inmate!(stockholm_user)
      visit root_path
    end
    it "should not have the content 'Stockholm Inmate Idea'" do
      page.should_not have_content("Stockholm Inmate Idea")
    end
  end

  describe "with madison friend" do 
    before(:each) do
      user.ignore_inmate!(other_user)
      user.unfriend!(other_user)
      user.inmate!(other_user)
      user.friend!(other_user)
      visit root_path
    end
    it "should have content 'Friends Only Idea'" do
      page.should have_content("Friends Only Idea")
    end
  end

  describe "RSVPd friends only event is visible" do
    before do
      user.rsvp_in!(friends_only)
      visit root_path
    end
    it "should have the content 'Regular Test Idea'" do
      page.should have_content("Madison Test Idea")
    end
    it "should have the content 'Friends Only Idea'" do
      page.should have_content("Friends Only Idea")
    end
  end

  describe "mini calendar" do 
    before do
      @time = FactoryGirl.create(:event,
                        parent: madison_idea,
                        city: city,
                        user: user,
                        chronic_starts_at: "#{Time.zone.now + 1.days}", 
                        ends_at: "#{Time.zone.now + 1.day + 2.hours}",
                        duration: 2,
                        address: "my house",
                        title: "Test Time"
                        )
      visit root_path
    end
    it "should not display instructions in the mini calendar" do
      page.should_not have_selector(".mini_calendar_explanation")
    end
    it "should have content 'Test Time" do
      page.should have_content("Test Time")
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

  describe "My User#Show page" do 
    before do 
      @event = FactoryGirl.create(:event, 
                 :user => user, 
                 :city => city,
                 :parent => madison_idea,
                  chronic_starts_at: "#{Time.zone.now + 1.days}", 
                  ends_at: "#{Time.zone.now + 1.day + 2.hours}",
                  duration: 2,)
      user.rsvp_in!(@event)
      visit user_path(user)
    end
    it "should have the content 'upcoming ideas'" do
      page.should have_content("Upcoming Ideas")
    end
    it "should have the content user name and last name inital" do
      page.should have_content("#{user.first_name_with_last_initial}")
    end
  end

  describe "other_user's User#Show page" do
    before do
      @event = FactoryGirl.create(:event, 
                 :user => user, 
                 :city => city,
                 :parent => madison_idea,
                  chronic_starts_at: "#{Time.zone.now + 1.days}", 
                  ends_at: "#{Time.zone.now + 1.day + 2.hours}",
                  duration: 2,)
      user.rsvp_in!(@event)
      user.unfriend!(other_user)
      user.ignore_inmate!(other_user)
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
      @event = FactoryGirl.create(:event, 
                       :user => user, 
                       :city => city,
                       :parent => madison_idea,
                        chronic_starts_at: "#{Time.zone.now + 1.days}", 
                        ends_at: "#{Time.zone.now + 1.day + 2.hours}",
                        duration: 2,)
      visit event_path(madison_idea)
    end 
    it "should have the content Date Tomorrow" do
      page.should have_content((Time.now + 1.day).strftime('%A'))
    end
  end

  describe "Video and URL image Event#Show" do
     before do
      @event = FactoryGirl.create(:event, 
                       :user => user, 
                       :city => city,
                       :parent => madison_idea,
                        chronic_starts_at: "#{Time.zone.now + 1.days}", 
                        ends_at: "#{Time.zone.now + 1.day + 2.hours}",
                        duration: 2,
                       :promo_vid => "http://www.youtube.com/watch?v=62rgESCyB2g&feature=g-vrec",
                       :promo_url => "http://ecx.images-amazon.com/images/I/51d2Qu4RGFL._BO2,204,203,200_PIsitb-sticker-arrow-click,TopRight,35,-76_AA300_SH20_OU01_.jpg")
      visit event_path(madison_idea)
    end 
    it "should have the content Date Tomorrow" do
      page.should have_content((Time.now + 1.day).strftime('%A'))
    end
  end

  describe "friending" do    
    before do
      user.friend!(other_user)
    end

    it "should be friends with other_user" do
      other_user.inmates.should include(user)
      user.friends.should include(other_user)
      other_user.friends.should_not include(user)
    end
  end

  describe "removing a friendship" do
    before do
      user.friend!(other_user)
      user.unfriend!(other_user)
    end

    it "should not be friends with other_user" do
      user.friends.should_not include(other_user)
      user.inmates.should include(other_user)
      other_user.inmates.should include(user)
      other_user.friends.should_not include(user)
    end
  end
end

  #describe "visiting stockholm" do
    # before do
    #   user.update_attributes(:city => stockholm)
    #   visit root_path
    # end
    # it "should not have madison ideas"
    # end
    # it "should have stockholm inmate ideas"
    # end
  #before do 
  #end