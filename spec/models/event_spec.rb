require 'spec_helper'

describe Event do

  let(:user) { FactoryGirl.create(:user) }
	before { @event = user.events.build(title: "Fun Get Together",
																			starts_at: 2.hours.ago,
																			ends_at: 1.hour.ago,
																			location: "My house",
																			description: "Going to be totally fun",
																			) }
  
  subject { @event }

	it { should respond_to(:title) }
	it { should respond_to(:description) }
	it { should respond_to(:starts_at) }
	it { should respond_to(:ends_at) }
	it { should respond_to(:location) }
  it { should respond_to(:user_id) }

  it { should be_valid }

  describe "when user_id is not present" do
    before { @event.user_id = nil }
    it { should_not be_valid }
  end

 describe "accessible attributes" do
  it "should not allow access to user_id" do
    expect do
      Event.new(user_id: user.id)
    end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)   
  end
end
end