class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_if_first_use

  private

  def check_if_first_use
    silence_action do
      if ApplicationConfiguration.count == 0
        redirect_to welcome_settings_path
      end
    end
  end

  def silence_action
    Rails.logger.silence do
      yield
    end
  end

  def app_config
    ApplicationConfiguration.first
  end

  def alpha_filter_scope(scope)
    if params[:alpha].present?
      alpha = "#{params[:alpha]}%".downcase
      scope = scope.alphabetical.where('lower(title) like :q', q: alpha)
    end
    scope
  end

  def paged(scope)
    @_is_paged = true
    @current_page = cur_page
    @next_page = cur_page + 1
    @prev_page = cur_page - 1

    prev_offset = (@current_page * results_per_page) - 1
    next_offset = (@current_page * results_per_page) + results_per_page

    prev_resource = scope.limit(1).offset(prev_offset).first if prev_offset > 0
    next_resource = scope.limit(1).offset(next_offset).first if next_offset > 0
    current_resources = scope.paginated(@current_page, results_per_page).to_a

    [prev_resource, current_resources, next_resource]
  end

  def cur_page
    page = params[:page].to_i || 0
  end

  private

  def results_per_page
    48
  end

end
