class DriversController < ApplicationController
  def index 
    @drivers = Driver.page(params[:page]).per(25)
  end

  def show 
    id = params[:id].to_i
    @driver = Driver.find(id)
    @trips = @driver.trips
    @earnings = Driver.earnings(@trips)
    @average_rating = Driver.average_rating(@trips)

    if !@driver.nil?
      @url = "http://thecatapi.com/api/images/get?format=src&type=gif&timestamp="
    end

    if @driver.nil?
      head :not_found
      return
    end

    rescue ActiveRecord::RecordNotFound
      head :not_found
    rescue ZeroDivisionError
      0.0
  end

  def new 
    @driver = Driver.new
  end

  def create 
    @driver = Driver.create(driver_params)
    if @driver.id?
      redirect_to root_path
    else
      render :new
    end

  rescue ActionController::ParameterMissing
    redirect_to new_driver_path
  end

  def edit 
    driver_id = params[:id].to_i
    @driver = Driver.find_by(id: driver_id)

    if @driver.nil?
      redirect_to drivers_path
      return
    end
  end

  def update 
    @driver = Driver.find_by(id: params[:id])

    if @driver.nil?
      head :not_found
      return
    elsif @driver.update(driver_params)
      redirect_to drivers_path
      return
    else
      render :edit
      return
    end
  end

  def destroy 
    driver_id = params[:id]
    @driver = Driver.find_by(id: driver_id)

    if @driver.nil?
      redirect_to drivers_path
      return
    end

    @driver.trips.each do |trip|
      trip.driver = nil
    end

    @driver.destroy

    redirect_to drivers_path
    return
  end


  
  private

  def driver_params
    return params.require(:driver).permit(:name, :vin)
  end
end
