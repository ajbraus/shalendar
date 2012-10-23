require 'spec_helper'

describe "authentications/show" do
  before(:each) do
    @authentication = assign(:authentication, stub_model(Authentication,
      :email => "Email",
      :uid => 1,
      :user => nil,
      :ex => "Ex",
      :create => "Create",
      :destroy => "Destroy"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Email/)
    rendered.should match(/1/)
    rendered.should match(//)
    rendered.should match(/Ex/)
    rendered.should match(/Create/)
    rendered.should match(/Destroy/)
  end
end
