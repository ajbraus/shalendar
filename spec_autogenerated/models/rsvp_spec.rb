require 'spec_helper'

describe Rsvp do

  let(:guest) { FactoryGirl.create(:user) }
  let(:plan) { FactoryGirl.create(:event) }
  let(:rsvp) { guest.rsvps.build(event_id: plan.id) }

  subject { rsvp }

  it { should be_valid }

  describe "accessible attributes" do
    it "should not allow access to guest_id" do
      expect do
        Rsvp.new(guest_id: guest.id)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "guest methods" do    
    it { should respond_to(:guest) }
    it { should respond_to(:plan) }
    its(:guest) { should == guest }
    its(:plan) { should == plan }
  end

  describe "when plan id is not present" do
    before { rsvp.event_id = nil }
    it { should_not be_valid }
  end

  describe "when guest id is not present" do
    before { rsvp.guest_id = nil }
    it { should_not be_valid }
  end

end