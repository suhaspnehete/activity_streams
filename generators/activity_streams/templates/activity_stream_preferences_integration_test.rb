#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# Template to generate the ActivityStreamPreferencesControllerTest
require File.dirname(__FILE__) + '/../test_helper'
class ActivityStreamPreferencesControllerTest < ActionController::IntegrationTest

  def all_locations
    locations  = []
    ACTIVITY_STREAM_ACTIVITIES.each_key do |key|
      [:public_location, :logged_in_location, :feed_location].each do |location|
        locations << "#{key}.#{location}"
      end
    end
    locations
  end

  def test_follow_activity_shows_in_<%= user_model_table %>_view
    post '/sessions', :login => 'fred', :password => '123123'
    assert_response :redirect

    post '/activity_stream_preferences', :<%= user_model_id %> => <%= user_model_table %>(:fred).id, :locations => all_locations
    assert_redirected_to ("/activity_stream_preferences")    

    post '/set_my_feeds', :id => 1, :creators => ['1'], :feed_digest_option => 'daily'
    get "/<%= user_model_table %>/#{<%= user_model_table %>(:fred).id}"
    assert_match(/.*#{<%= user_model_table %>(:fred).friendly_name}<\/a>..<span class='ActivityStreamVerb'>now follows.*/m, @response.body)
  end

  def test_follow_activity_shows_in_public_<%= user_model_table %>_view
    post '/sessions', :login => 'fred', :password => '123123'
    assert_response :redirect

    post '/activity_stream_preferences', :<%= user_model_id %> => <%= user_model_table %>(:fred).id, :locations => all_locations
    assert_redirected_to ("/activity_stream_preferences")    

    post '/set_my_feeds', :id => 1, :creators => ['1'], :feed_digest_option => 'daily'
    post '/logout'

    get "/<%= user_model_table %>/#{<%= user_model_table %>(:fred).id}"

    assert_match(/.*#{<%= user_model_table %>(:fred).friendly_name}<\/a>..<span class='ActivityStreamVerb'>now follows.*/m, @response.body)
  end

  def test_follow_activity_hidden_by_preferences_in_logged_in_<%= user_model_table %>_view
    post '/sessions', :login => 'fred', :password => '123123'
    assert_response :redirect

    post '/activity_stream_preferences', :<%= user_model_id %> => <%= user_model_table %>(:fred).id, :locations => ( all_locations - ['follow_creator.logged_in_location'])
    assert_redirected_to ("/activity_stream_preferences")    

    post '/set_my_feeds', :id => 1, :creators => ['1'], :feed_digest_option => 'daily'
    get "/<%= user_model_table %>/#{<%= user_model_table %>(:fred).id}"
    assert_no_match(/.*#{<%= user_model_table %>(:fred).friendly_name}<\/a>..<span class='ActivityStreamVerb'>now follows.*/m, @response.body)
  end

  def test_follow_activity_hidden_by_preferences_in_public_<%= user_model_table %>_view
    post '/sessions', :login => 'fred', :password => '123123'
    assert_response :redirect

    post '/activity_stream_preferences', :<%= user_model_id %> => <%= user_model_table %>(:fred).id, :locations => (all_locations - ['follow_creator.public_location'])
    assert_redirected_to ("/activity_stream_preferences")    

    post '/set_my_feeds', :id => 1, :creators => ['1'], :feed_digest_option => 'daily'

    post '/logout'

    get "/<%= user_model_table %>/#{<%= user_model_table %>(:fred).id}"

    assert_no_match(/.*#{<%= user_model_table %>(:fred).friendly_name}<\/a>..<span class='ActivityStreamVerb'>now follows.*/m, @response.body)
  end

end
