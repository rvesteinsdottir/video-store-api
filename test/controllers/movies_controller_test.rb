require "test_helper"

describe MoviesController do
  describe "index" do
    it "responds with JSON and success" do
      get movies_path

      expect(response.header['Content-Type']).must_include 'json'
      must_respond_with :ok
    end

    it "responds with an array of movie hashes" do
      get movies_path
  
      body = JSON.parse(response.body)
  
      expect(body).must_be_instance_of Array
      body.each do |movie|
        expect(movie).must_be_instance_of Hash
        expect(movie.keys.sort).must_equal ["id", "title", "release_date"]
      end
    end

    it "will respond with an empty array when there are no movies" do
      Movie.destroy_all
  
      get movies_path
      body = JSON.parse(response.body)
  
      expect(body).must_be_instance_of Array
      expect(body).must_equal []
    end
  end

  describe "show" do
    before do
      Movie.create(title: "random")
    end
    let (:valid_movie_id) { Movie.all.first }
    let (:invalid_movie_id) { -1 }
    it "responds with JSON and success for valid movie" do      
      get movie_path(valid_movie_id.id)

      expect(response.header['Content-Type']).must_include 'json'
      must_respond_with :ok
    end

    it "responds with a movie hash" do
      get movie_path(valid_movie_id.id)
  
      body = JSON.parse(response.body)
  
      expect(body).must_be_instance_of Hash
      expect(body.keys.sort).must_equal ["id", "title", "release_date", "overview", "inventory", "available_inventory"].sort
      must_respond_with :ok
    end

    it "responds with JSON and not found error for invalid movie" do
      get movie_path(invalid_movie_id)

      body = JSON.parse(response.body)

      expect(body).must_be_instance_of Hash
      
      expect(body["errors"]).must_equal ["not found"]

      must_respond_with :not_found
    end
  end

  describe "create" do
    it "creates new movie with valid parameters" do
      new_movie_params = {
        title: "new movie",
        overview: "new movie description",
        release_date: 2019,
        inventory: 10
      }

      expect {
        post movies_path, params: new_movie_params
      }.must_change "Movie.count", 1

      body = JSON.parse(response.body)

      expect(body.keys.length).must_equal 1
      expect(body.keys).must_equal ["id"]
      expect(body["id"]).must_be_instance_of Integer
      expect(body["id"]).must_equal Movie.find_by(title: new_movie_params[:title]).id
      must_respond_with :ok
    end

    it "renders error if unable to save movie " do
      new_movie_params = {
        overview: "new movie description",
        release_date: 2019,
        inventory: 10
      }

      expect {
        post movies_path, params: new_movie_params
      }.wont_change "Movie.count"

      must_respond_with :bad_request
    end
  end
end