class ApplicationController < ActionController::Base
  before_action :set_cart_count

  private

  def set_cart_count
    if session[:cart].is_a?(Hash)
      @cart_count = session[:cart].values.map(&:to_i).sum
    elsif session[:cart].is_a?(Array)
      @cart_count = session[:cart].length
    else
      @cart_count = 0
    end
  end
end
