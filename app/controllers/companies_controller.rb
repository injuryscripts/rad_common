class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show edit update]

  def show; end

  def edit; end

  def update
    if @company.update(permitted_params)
      redirect_to '/rad_common/company', notice: 'Settings were successfully updated.'
    else
      render :edit
    end
  end

  private

    def set_company
      @company = Company.main
      authorize @company
    end

    def base_params
      %i[name phone_number website email address_1 address_2 city state zipcode validity_checked_at
         valid_user_domains_entry timezone]
    end

    def permitted_params
      params.require(:company).permit(base_params + Rails.configuration.rad_common.additional_company_params)
    end
end
