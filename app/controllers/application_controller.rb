class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_if_first_use

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

end
