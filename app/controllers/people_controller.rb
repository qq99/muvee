class PeopleController < ApplicationController

  RESULTS_PER_PAGE = 56

  def index
    @section = :all
    scope = Person.order(full_name: :asc)
    scope = alpha_filter_scope(scope)

    @prev_person, @people, @next_person = paged(scope)
  end

  def show
    @section = :people
    @person = Person.find(params[:id])
    @items = @person.videos_and_series
  end

  private

  def alpha_filter_scope(scope)
    if params[:alpha].present?
      alpha = "#{params[:alpha]}%".downcase
      scope = scope.alphabetical.where('lower(full_name) like :q', q: alpha)
    end
    scope
  end

end
