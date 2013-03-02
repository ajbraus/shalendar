# require 'spec_helper'

# describe 'Comments' do 
	
#   let(:city) { FactoryGirl.create(:city)}
#   let(:user) { FactoryGirl.create(:user, :city => city) }
#   let(:idea) { FactoryGirl.create(:event, 
#                      :user => user,
#                      :city => city,
#                      :chronic_starts_at => "#{Time.now + 1.day}", 
#                      :ends_at => "#{Time.now + 1.day + 2.hours}",
#                      :one_time => 'f',
#                      :title => "Regular Test Idea") }

# 	before(:each) do
#     visit new_user_session_path
#     fill_in "Email",    with: user.email
#     fill_in "Password", with: user.password
#     click_button "log.in"
#     visit event_path(idea)
#   end

# 	describe 'Create Comment' do 
# 		before do
# 			fill_in "comment_content", with: "Testing"
# 			click_button "new_comment_button"
# 		end

# 		# it 'should email friends of the commenter and the host of the idea' do 
		
# 		# end

# 		it 'should have the comment content' do
# 			page.should have_content("Testing")
# 		end
# 	end
	
# 	describe 'Destroy Comment' do
# 		before do 
# 			click_link "delete_comment"
# 		end

# 		it 'should not have the comment content' do
# 			page.should_not have_content("Testing")
# 		end
# 	end



# # END OF SPEC
# end