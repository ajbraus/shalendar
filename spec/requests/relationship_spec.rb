require 'spec_helper'

describe "Pages after sign up / sign in" do

  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  let(:follwed_vendor) { FactoryGirl.create(:vendor) }
  let(:relationship) { follower.relationships.build(followed_id: followed.id) }

  subject { relationship }

  after(:all)  { User.delete_all }

  before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: vendor.email
    fill_in "Password", with: vendor.password
    click_button "Sign in"
  end
  
  after(:each) { Event.delete_all }

  describe "friending" do
    let(:other_user) { FactoryGirl.create(:user) }    
    before do
      @user.save
      @user.follow!(other_user)
    end

    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
  end

  # describe "Friending a user" do
  #   before do 
  #     visit manage_friends_path
  #   end

  #   it "should have the Date" do
  #     page.should_not have_content("Vendor Dashboard")
  #     page.should have_content("#{Time.now.strftime('%A')}")
  #   end
  # end

  # describe "Friending a Vendor" do

  # end

  # describe "Removing a Friend" do 

  # end

  # describe "removing a vendor friend" do
 
  # end

end