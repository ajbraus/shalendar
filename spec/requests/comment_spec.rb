require 'spec_helper'

describe 'Comments' do 
	
	let(:user) { FactoryGirl.create(:user) }
  let(:event) { FactoryGirl.create(:event, :user_id => user.id, 
                       :chronic_starts_at => "Tomorrow at 3pm") }

	before(:each) do
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Login"
    visit event_path(event)
  end

	describe 'Create Comment' do 
		before do
			fill_in "comment_content", with: "Testing"
			click_button "w"
		end

		it 'should have the comment content' do
			page.should have_content("Testing")
		end
			
		describe 'Destroy Comment' do
			before do 
				click_link "delete_comment"
			end

			it 'should not have the comment content' do
				page.should_not have_content("Testing")
			end
		end

	end



# END OF SPEC
end