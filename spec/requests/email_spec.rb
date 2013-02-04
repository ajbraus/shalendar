require 'spec_helper'

describe "emails" do
	let(:city) { FactoryGirl.create(:city)}
  let(:user) { FactoryGirl.create(:user, :city => city) }
  let(:event) { FactoryGirl.create(:event, :user_id => user.id, 
                       :chronic_starts_at => "#{Time.now + 1.day}", 
                       :ends_at => "#{Time.now + 1.day + 2.hours}") }


	describe "digest email" do
		it "emails users every four days a digest email" do

		end
	end
end	