require 'spec_helper'

# save_and_open_page

describe "new idea page" do

  let(:city) { FactoryGirl.create(:city) }
	let(:user) { FactoryGirl.create(:user, :city => city) }

  before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "log.in"
    visit '/new_idea'
  end

  it "should have title field" do
  	page.should have_selector("#new_idea_title")
  end

  describe "making a new idea" do
  	before(:each) do 
			visit '/new_idea'
  		fill_in "new_idea_title", with: "Awesome Idea"
  		fill_in "new_idea_description", with: "I am a great description"
  		click_button 'Create Idea'
  	end

  	it "should have title of idea" do
  		page.should have_content("Awesome Idea")
  	end
  end
end
