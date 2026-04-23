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

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to products_path, notice: "Product created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])

    if @product.update(product_params)
      redirect_to products_path, notice: "Product updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to products_path, notice: "Product deleted successfully!"
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

  def increase_quantity
    normalize_cart_session

    product_id = params[:id].to_s
    session[:cart][product_id] ||= 0
    session[:cart][product_id] += 1

    redirect_to cart_path
  end

  def decrease_quantity
    normalize_cart_session

    product_id = params[:id].to_s

    if session[:cart][product_id]
      session[:cart][product_id] -= 1
      session[:cart].delete(product_id) if session[:cart][product_id] <= 0
    end

    redirect_to cart_path
  end

  def checkout
  normalize_cart_session

  unless user_signed_in?
    redirect_to new_user_session_path, alert: "Please log in before checking out."
    return
  end

  # First pass: validate stock
  session[:cart].each do |product_id, quantity|
    product = Product.find_by(id: product_id)
    next unless product

    quantity = quantity.to_i

    if quantity <= 0
      redirect_to cart_path, alert: "Invalid quantity in cart."
      return
    end

    if product.stock < quantity
      redirect_to cart_path, alert: "Not enough stock for #{product.name}."
      return
    end
  end

  order = current_user.orders.create(total: 0)
  total = 0

  session[:cart].each do |product_id, quantity|
    product = Product.find_by(id: product_id)
    next unless product

    quantity = quantity.to_i
    subtotal = product.price * quantity

    order.order_items.create(
      product: product,
      quantity: quantity,
      price: product.price
    )

    total += subtotal

    product.update(stock: product.stock - quantity)
  end

  order.update(total: total)
  session[:cart] = {}

  redirect_to orders_path, notice: "Order placed successfully!"
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

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :category, :image)
  end

  before_action :authenticate_user!, except: [ :index, :show ]
end
