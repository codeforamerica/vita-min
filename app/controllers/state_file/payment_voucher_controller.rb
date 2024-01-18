class StateFile::PaymentVoucherController < ApplicationController
  def show
    case params[:us_state]
    when 'az'
      redirect_to ActionController::Base.helpers.asset_path('/pdfs/AZ-140V.pdf')
    when 'ny'
      send_data PdfFiller::Ny201VPdf.new.output_file.read, filename: "it201v_1223.pdf", disposition: 'inline'
    else
      redirect_to '404'
    end
  end
end

