require 'spec_helper'

describe "Relationships" do

  let(:user)          { FactoryGirl.create(:user) }
  let(:other_user)    { FactoryGirl.create(:user) }
  let(:vendor)        { FactoryGirl.create(:vendor) }
  let(:relationship)  { user.relationships.build(followed_id: other_user.id) }

  after(:all)         { User.delete_all }

  subject { user }

  before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Login"
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

# END OF SPEC
end