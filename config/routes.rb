Rottenpotatoes::Application.routes.draw do
  resources :movies do
    collection do
      get 'search_tmdb'
      post 'add_movie'
    end
  end

  # map '/' to be a redirect to '/movies'
  root to: redirect('/movies')
end