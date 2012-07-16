require "spec_helper"

describe Notifier do
  
  describe "welcome" do
    let(:mail) { Notifier.welcome }

    it "renders the headers" do
      mail.subject.should eq("Welcome to Calenshare")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "cancellation" do
    let(:mail) { Notifier.cancellation }

    it "renders the headers" do
      mail.subject.should eq("Event Cancellation")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "confirm_follow" do
    let(:mail) { Notifier.confirm_follow }

    it "renders the headers" do
      mail.subject.should eq("Confirm follow")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "rsvp_reminder" do
    let(:mail) { Notifier.rsvp_reminder }

    it "renders the headers" do
      mail.subject.should eq("Rsvp reminder")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "event_tipped" do
    let(:mail) { Notifier.event_tipped }

    it "renders the headers" do
      mail.subject.should eq("Event tipped")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "digest" do
    let(:mail) { Notifier.digest }

    it "renders the headers" do
      mail.subject.should eq("Digest")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
