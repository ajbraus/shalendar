require 'spec_helper'

describe "Static pages" do

  describe "Landing Page" do

    before do
      visit root_path
    end

    it "should have the tagline" do
      page.should have_content('Do Great Things With Friends')
    end
  end
end