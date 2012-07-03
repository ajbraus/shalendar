require 'spec_helper'

describe "Static pages" do

  describe "Home page" do

    it "should have the content 'Shalendar'" do
      visit '/'
      page.should have_content('Shalendar')
    end
  end

  describe "About page" do

    it "should have the content 'About'" do
      visit '/about'
      page.should have_content('About')
    end
  end

    describe "Contact" do

    it "should have the content 'Contact'" do
      visit '/contact'
      page.should have_content('Contact')
    end
  end
end