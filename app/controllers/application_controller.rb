class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys:
      [:first_name, :last_name, :avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: 
      [:first_name, :last_name, :avatar,:remove_avatar])
  end

  # rescue_from CanCan::AccessDenied do |exception|
  #   render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
  #   ## to avoid deprecation warnings with Rails 3.2.x (and incidentally using Ruby 1.9.3 hash syntax)
  #   ## this render call should be:
  #   # render file: "#{Rails.root}/public/403", formats: [:html], status: 403, layout: false
  # end
end
