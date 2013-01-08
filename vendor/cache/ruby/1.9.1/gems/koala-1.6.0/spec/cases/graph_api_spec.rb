require 'spec_helper'

describe 'Koala::Facebook::GraphAPIMethods' do
  before do
    @api = Koala::Facebook::API.new(@token)
    # app API
    @app_id = KoalaTest.app_id
    @app_access_token = KoalaTest.app_access_token
    @app_api = Koala::Facebook::API.new(@app_access_token)
  end

  describe 'post-processing for' do
    let(:post_processing) { lambda {} }

    # Most API methods have the same signature, we test get_object representatively
    # and the other methods which do some post-processing locally
    context '#get_object' do
      it 'returns result of block' do
        result = {"id" => 1, "name" => 1, "updated_time" => 1}
        @api.stub(:api).and_return(result)
        post_processing.should_receive(:call).
          with(result).and_return('new result')
        @api.get_object('koppel', &post_processing).should == 'new result'
      end
    end

    context '#get_picture' do
      it 'returns result of block' do
        result = "http://facebook.com/"
        @api.stub(:api).and_return("Location" => result)
        post_processing.should_receive(:call).
          with(result).and_return('new result')
        @api.get_picture('lukeshepard', &post_processing).should == 'new result'
      end
    end

    context '#fql_multiquery' do
      before do
        @api.should_receive(:get_object).and_return([
          {"name" => "query1", "fql_result_set" => [{"id" => 123}]},
          {"name" => "query2", "fql_result_set" => ["id" => 456]}
        ])
      end

      it 'is called with resolved response' do
        resolved_result = {
          'query1' => [{'id' => 123}],
          'query2' => [{'id'=>456}]
        }
        post_processing.should_receive(:call).
          with(resolved_result).and_return('id'=>'123', 'id'=>'456')
        @api.fql_multiquery({}, &post_processing).should ==
          {'id'=>'123', 'id'=>'456'}
      end
    end

    context '#get_page_access_token' do
      it 'returns result of block' do
        token = Koala::MockHTTPService::APP_ACCESS_TOKEN
        @api.stub(:api).and_return("access_token" => token)
        post_processing.should_receive(:call).
          with(token).and_return('base64-encoded access token')
        @api.get_page_access_token('facebook', &post_processing).should ==
          'base64-encoded access token'
      end
    end
  end
end
