class Portal::AdminController < Portal::BaseController
  def index
    # TODO: admin_service_requests_by_status returns *sub* service
    # requests, so this is a misnomer
    @service_requests = @user.admin_service_requests_by_status
  end

  def delete_toast_message
    @message = ToastMessage.find(params[:id])
    @message.destroy
    render :nothing => true
  end
end
