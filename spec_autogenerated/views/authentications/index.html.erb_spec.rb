require 'spec_helper'

describe "authentications/index" do
  before(:each) do
    assign(:authentications, [
      stub_model(Authentication,
        :email => "Email",
        :uid => 1,
        :user => nil,
        :ex => "Ex",
        :create => "Create",
        :destroy => "Destroy"
      ),
      stub_model(Authentication,
        :email => "Email",
        :uid => 1,
        :user => nil,
        :ex => "Ex",
        :create => "Create",
        :destroy => "Destroy"
      )
    ])
  end

  it "renders a list of authentications" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Ex".to_s, :count => 2
    assert_select "tr>td", :text => "Create".to_s, :count => 2
    assert_select "tr>td", :text => "Destroy".to_s, :count => 2
  end
end
