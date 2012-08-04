require 'spec_helper'

describe "event/2" do
  before(:each) do
    assign(:comment, stub_model(Comment,
      :content => "MyString",
      :event => nil
    ).as_new_record)
  end

  it "renders new comment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => comments_path, :method => "post" do
      assert_select "input#comment_content", :name => "comment[content]"
      assert_select "input#comment_event", :name => "comment[event]"
    end
  end
end
