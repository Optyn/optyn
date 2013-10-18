module Merchants
  module LabelSetUpdate
    private

    def create_label_helper_method_called
	    existing_label = current_shop.labels.find_by_name(params[:label].strip)
	    label = current_shop.labels.create(name: params[:label].strip) unless existing_label.present?
	    ref_label = existing_label.present? ? existing_label : label
	    user_label = UserLabel.find_or_create_by_user_id_and_label_id(user_id: params[:user_id], label_id: ref_label.id)

	    render json: (label.attributes.except('shop_id', 'created_at', 'updated_at') rescue []).to_json
	  end

	  def update_labels_helper_method_called
	    user = User.find(params[:user_id])
	    label_ids = params[:label_ids].collect(&:to_i) rescue []
	    user.adjust_labels(label_ids)
	    render nothing: true
	  end
  end
end