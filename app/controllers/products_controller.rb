class ProductsController < ApplicationController
  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
  end

  def add_to_cart
    session[:cart] ||= []
    session[:cart] << params[:id]
    redirect_to cart_path
  end

  def cart
    ids = session[:cart] || []
    @cart_products = Product.find(ids)
  end

  def remove_from_cart
    session[:cart] ||= []
    session[:cart].delete_at(session[:cart].index(params[:id])) if session[:cart].include?(params[:id])
    redirect_to cart_path
  end
end
