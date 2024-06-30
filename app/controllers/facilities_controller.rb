class FacilitiesController < ApplicationController

  def geo
    respond_to do |format|
      format.json do
        @facilities = Facility.page(page).per(10)
      end
    end
  end

  private

  def page
    params[:page] || 1
  end
end