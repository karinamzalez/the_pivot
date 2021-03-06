class OrdersController < ApplicationController
  around_action :wrap_in_transaction, only: :create

  def index
    if current_user
      @orders = current_user.orders
    else
      render file: "/public/404"
    end
  end

  def show
    if current_user.orders.find(params[:id])
      @order = Order.find(params[:id])
    end
  end

  def create
    if current_user
      @user = current_user
      @order = OrderProcessor.new(@cart, @user).process_order
      session[:cart].clear
      redirect_to new_charge_path(order: @order)
    else
      flash[:info] = "Please login or create a new account before checking out."
      redirect_to login_path
    end
  end

private

  def wrap_in_transaction
    ActiveRecord::Base.transaction do
      begin
        yield
      end
    end
  end
end
