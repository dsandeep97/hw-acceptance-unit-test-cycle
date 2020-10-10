require 'rails_helper'

describe MoviesController do
  describe 'Search movies by the same director' do
    let!(:movie) { Movie.create({:title => 'Catch me if you can'})}
    let!(:seven) { Movie.create({:title => 'Seven', :director => 'David Fincher'})}
    let!(:socialnetwork) { Movie.create({:title => 'The Social Network', :director => 'David Fincher'})}

    it 'should call Movie.similar_movies' do
      expect(Movie).to receive(:similar_movies).with('Alladin')
      get :movie_with_same_director, { title: 'Alladin' }
    end

    it 'Need to assign similar movies if director exists' do
      movies = ['Seven', 'The Social Network']
      get :movie_with_same_director, { title: 'Seven' }
      expect(assigns(:similar_movies)).to eql(movies)
      expect(response).to render_template('movie_with_same_director')
    end

    it "should redirect to home page if director isn't known" do
      get :movie_with_same_director, { title: 'Catch me if you can' }
      expect(flash[:notice]).to match(/has no director info/)
      expect(response).to redirect_to(movies_path)
    end

    it "should return nil for empty director" do
      get :movie_with_same_director, { title: 'Catch me if you can' }
      expect(assigns(:similar_movies)).to eql(nil)
    end
  end

  describe 'Get Index' do
    it 'should get index' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'Update Movie' do
    let!(:movie) { Movie.create({:title => 'Catch me if you can', :director => 'Steven Spielberg'})}

    it 'should update the details' do
      put :update, {id: movie.id, :movie => {'director' => 'another name'}}
      expect(flash[:notice]).to match(/was successfully updated/)
      expect(response).to redirect_to(movie_path)
    end
  end

  describe 'Edit Movie' do
    let!(:movie) { Movie.create({:title => 'Catch me if you can', :director => 'Steven Spielberg'})}

    it 'should get edit page for movie' do
      get :edit, id: movie.id
      expect(response).to render_template('edit')
    end
  end

  describe 'Show Movie' do
    let!(:movie) { Movie.create({:title => 'Catch me if you can', :director => 'Steven Spielberg'})}

    it 'should get movie details page' do
      get :show, id: movie.id
      expect(response).to render_template('show')
    end
  end

  describe 'sort functionality testing' do
    it 'should title sort the movies' do
      get :index, {sort: 'title'}
      actual_order = Movie.order(:title)
      expect(actual_order).to eq(actual_order.sort)
      expect(assigns(:title_header)).to match(/hilite/)
      expect(response).to redirect_to movies_path(sort: :title, ratings: session[:ratings])
    end

    it 'should date sort the movies' do
      get :index, {sort: 'release_date'}
      actual_order = Movie.order(:release_date)
      expect(actual_order).to eq(actual_order.sort)
      expect(assigns(:date_header)).to match(/hilite/)
      expect(response).to redirect_to movies_path(sort: :release_date, ratings: session[:ratings])
    end
  end

  describe 'Create Movie' do
    movie_params = {:title => 'random title', :director => 'imaginary director', :rating => 'R', :description => 'random', :release_date => '6-Apr-1968'}
    let!(:movie) {Movie.create(movie_params)}

    it 'should create a movie' do
      expect(Movie).to receive(:create!).with(movie_params).and_return(movie)
      post :create, movie: movie_params
      expect(flash[:notice]).to match(/was successfully created/)
      expect(response).to redirect_to(movies_path)
    end
  end

  describe 'Delete movie' do
    movie_params = {:title => 'random title', :director => 'imaginary director', :rating => 'R', :description => 'random', :release_date => '6-Apr-1968'}
    let!(:movie) {Movie.create(movie_params)}

    it 'should set the flash' do
      delete :destroy, {id: movie.id}
      expect(flash[:notice]).to match(/deleted/)
      expect(response).to redirect_to(movies_path)
    end
  end
end
