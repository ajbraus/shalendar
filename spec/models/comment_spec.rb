require 'spec_helper'

describe Comment do
  let(:comment) { FactoryGirl.create(:comment) }
	before { @comment = event.comments.build( creator: "Test User",
																						content: "I'll be ten min late",
																						) }
  
  subject { @comment }


  it { should respond_to(:creator) }
	it { should respond_to(:content) }

  it { should be_valid }
end
