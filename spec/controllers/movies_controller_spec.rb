require 'rails_helper'

if RUBY_VERSION>='2.6.0'
  if Rails.version < '5'
    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        # hack to avoid MonitorMixin double-initialize error:
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        initialize
      end
    end
  else
    puts "Monkeypatch for ActionController::TestResponse no longer needed"
  end
end

describe MoviesController do
  describe 'searching TMDb' do

    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end

    it 'calls the model method that performs TMDb search' do
    expect(Movie).to receive(:find_in_tmdb).with(hash_including(title: 'hardware')).
        and_return(@fake_results)
      get :search_tmdb, {title: 'hardware'}
    end

    describe 'after valid search' do
      
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        get :search_tmdb, {title: 'hardware'}
      end

      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end
  end

  describe 'adding a movie from TMDb' do
    it 'creates a new movie in the database' do
      # Set up the movie parameters
      movie_attributes = { title: "Inception", rating: "R", release_date: "2010-07-16" }
  
      # Expect the Movie count to go up by 1
      expect {
        post :add_movie, movie: movie_attributes
      }.to change(Movie, :count).by(1)
    end
  
    it 'redirects back to the search page' do
      post :add_movie, movie: { title: "Inception", rating: "R" }
      expect(response).to redirect_to(search_tmdb_movies_path)
    end
  
    it 'sets a flash message on success' do
      post :add_movie, movie: { title: "Inception", rating: "R" }
      expect(flash[:success]).to be_present
      expect(flash[:success]).to eq("Inception was successfully added to RottenPotatoes.")
    end
  end
end