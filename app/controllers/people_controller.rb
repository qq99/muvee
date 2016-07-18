class PeopleController < ApplicationController
  def index
    @section = :all
  end

  def show
    @section = :people
    @person = Person.find(params[:id])
    @items = @person.videos_and_series
  end

end
