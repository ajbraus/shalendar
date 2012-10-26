require 'spec_helper'

describe "Pages after sign up / sign in" do

  let(:user) { FactoryGirl.create(:user) }

  before(:all) { FactoryGirl.create(:user)}
                 #FactoryGirl.create(:event) }
  after(:all)  { User.delete_all }

  before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
  end

  # describe "Event#Show" do
  #   before do
  #     visit
  #   end 
  #   it "should have the content 'Date Today'" do
  #     page.should have_content("#{Time.now.strftime('%A')}")
  #   end
  # end
end



