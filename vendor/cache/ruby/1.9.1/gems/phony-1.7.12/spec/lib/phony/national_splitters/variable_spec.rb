require 'spec_helper'

describe Phony::NationalSplitters::Variable do
  
  describe 'split' do
    context 'normal' do
      before(:each) do
        @splitter = Phony::NationalSplitters::Variable.new 4, ['1', '316', '67', '68', '669', '711']
      end
      it "handles Vienna" do
        @splitter.split('198110').should == ['0', '1', '98110']
      end
      it "handles some mobile services" do
        @splitter.split('66914093902').should == ['0', '669', '14093902']
      end
      it "handles Graz" do
        @splitter.split('3161234567891').should == ['0', '316', '1234567891']
      end
      it "handles Rohrau" do
        @splitter.split('2164123456789').should == ['0', '2164', '123456789']
      end
    end
    context 'special handling for using the variable size splitter for Swiss service numbers' do
      before(:each) do
        @splitter = Phony::NationalSplitters::Variable.new 2, ['800']
      end
      it "should handle swiss service numbers" do
        @splitter.split('800223344').should == ['0', '800', '223344']
      end
    end
  end
  
end