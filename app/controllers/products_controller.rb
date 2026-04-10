class ProductsController < ApplicationController
def index
  @products = Product.all

  if params[:search].present?
    @products = @products.where("name LIKE ? OR description LIKE ? OR category LIKE ?",
    "%#{params[:search]}%",
    "%#{params[:search]}%",
    "%#{params[:search]}%")
  end

  if params[:category].present?
    @products = @products.where(category: params[:category])
  end
end

  def show
    @product = Product.find(params[:id])
  end

  def add_to_cart
    normalize_cart_session

    product_id = params[:id].to_s
    session[:cart][product_id] ||= 0
    session[:cart][product_id] += 1

    redirect_to cart_path
  end

  def cart
    normalize_cart_session

    @cart_items = session[:cart].map do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product

      {
        product: product,
        quantity: quantity.to_i
      }
    end.compact
  end

  def remove_from_cart
    normalize_cart_session

    product_id = params[:id].to_s
    session[:cart].delete(product_id)

    redirect_to cart_path
  end

  def checkout
    normalize_cart_session

    order = Order.create(total: 0)
    total = 0

    session[:cart].each do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product

      quantity = quantity.to_i
      subtotal = product.price.to_f * quantity

      order.order_items.create(
        product: product,
        quantity: quantity,
        price: product.price
      )

      total += subtotal
    end

    order.update(total: total)
    session[:cart] = {}

    redirect_to products_path, notice: "Order placed successfully!"
  end

  private

  def normalize_cart_session
    if session[:cart].is_a?(Array)
      new_cart = {}
      session[:cart].each do |product_id|
        id = product_id.to_s
        new_cart[id] ||= 0
        new_cart[id] += 1
      end
      session[:cart] = new_cart
    else
      session[:cart] ||= {}
    end
  end
end
