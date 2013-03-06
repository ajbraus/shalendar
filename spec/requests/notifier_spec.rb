describe "Notifier", :type => :helper do
  def send_comment
    fill_in "comment_content", with: "Testing"
    click_button "new_comment_button"
  end

  def login
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_on "log.in"
  end

  def new_time
    click_on "makeATime"
    fill_in 'datetime', with: "#{Time.zone.now + 1.days}"
    fill_in 'event_duration', with: '2'
    click_on 'postNewTime'
  end

  let(:city) { FactoryGirl.create(:city)}
  let(:user) { FactoryGirl.create(:user, :city => city) }
  let(:other_user) { FactoryGirl.create(:user, :city => city) }
  let(:third_user) { FactoryGirl.create(:user, :city => city) }

  let(:idea) { FactoryGirl.create(:event, 
                     :user => other_user,
                     :city => city,
                     :one_time => 'f',
                     :title => "Regular Test Idea") }
  let(:user_idea) { FactoryGirl.create(:event, 
                     :user => other_user,
                     :city => city,
                     :one_time => 'f',
                     :title => "Regular Test Idea") }

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    login
  end

  it "should send welcome email to new user email" do  
    user.send_welcome
    Delayed::Job.last.handler.should have_content(user.email)
  end

  it 'should email host a comment' do 
    visit event_path(idea)
    send_comment
    
    Delayed::Job.last.handler.should have_content(other_user.email)
  end

  it 'should email a friend a comment' do
    third_user.rsvp_in!(idea)
    third_user.friend!(user)
    visit event_path(idea)
    send_comment

    Delayed::Job.last.handler.should have_content(third_user.email)
  end

  it 'should email all guests if host is commenting' do
    third_user.rsvp_in!(idea)
    visit event_path(user_idea)
    send_comment
    
    Delayed::Job.last.handler.should have_content(third_user.email)
  end

  it 'should email all guests of parent when new time is posted (except the host of the time) ' do
    third_user.rsvp_in!(idea)
    user.rsvp_in!(idea)
    visit event_path(idea)
    new_time

    Delayed::Job.last.handler.should have_content(third_user.email)
  end
end