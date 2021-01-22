require 'test_helper'

class VideosControllerTest < ActionDispatch::IntegrationTest

  describe "index" do
    it "returns a JSON array" do
      get videos_url
      assert_response :success
      expect(@response.headers['Content-Type']).must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      expect(data).must_be_kind_of Array
    end

    it "should return many video fields" do
      get videos_url
      assert_response :success

      data = JSON.parse @response.body
      data.each do |video|
        expect(video).must_include "title"
        expect(video).must_include "release_date"
      end
    end

    it "returns all videos when no query params are given" do
      get videos_url
      assert_response :success

      data = JSON.parse @response.body
      expect(data.length).must_equal Video.count

      expected_names = {}
      Video.all.each do |video|
        expected_names[video["title"]] = false
      end

      data.each do |video|
        expect(
          expected_names[video["title"]]
        ).must_equal false, "Got back duplicate video #{video["title"]}"

        expected_names[video["title"]] = true
      end
    end
  end

  describe "show" do
    it "Returns a JSON object" do
      get video_url(title: videos(:one).title)
      assert_response :success
      expect(@response.headers['Content-Type']).must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      expect(data).must_be_kind_of Hash
    end

    it "Returns expected fields" do
      get video_url(title: videos(:one).title)
      assert_response :success

      video = JSON.parse @response.body
      expect(video).must_include "title"
      expect(video).must_include "overview"
      expect(video).must_include "release_date"
      expect(video).must_include "inventory"
      expect(video).must_include "available_inventory"
    end

    it "Returns an error when the video doesn't exist" do
      get video_url(title: "does_not_exist")
      assert_response :not_found

      data = JSON.parse @response.body
      expect(data).must_include "errors"
      expect(data["errors"]).must_include "title"
    end
  end

  describe "create" do
    it "creates a video" do
      video1 = {
        "title": 'Hidden Figures',
        "overview": 'Some text',
        "release_date": '1960-06-16',
        "inventory": 8,
        "external_id": 99999
      }

      expect {
        post videos_path, params: video1
      }.must_differ "Video.count", 1
    end

    it "won't add duplicate videos" do
      video1 = {
        "title": 'Hidden Figures',
        "overview": 'Some text',
        "release_date": '1960-06-16',
        "inventory": 8,
        "external_id": 99999
      }

      post videos_path, params: video1

      video2 = {
        "title": 'Video',
        "overview": 'Some new text',
        "release_date": '1990-06-16',
        "inventory": 4,
        "external_id": 99999
      }

      expect {
        post videos_path, params: video2
      }.wont_differ "Video.count"
    end
  end

end
