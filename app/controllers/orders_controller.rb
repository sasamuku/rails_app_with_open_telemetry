class OrdersController < ApplicationController
  def create
    Order.create(amount: params[:amount], status: "pending")
    render json: { status: "success" }, status: :ok
  end

  def index
    render json: { orders: Order.all }, status: :ok
  end
end
