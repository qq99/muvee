class PeopleController < ApplicationController
  def index
    @section = :all
  end

  def show
    @section = :people
    @person = Person.find(params[:id])
  end

end
