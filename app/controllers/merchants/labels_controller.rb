class Merchants::LabelsController < Merchants::BaseController
  # GET /merchants/labels
  # GET /merchants/labels.json
  def index
    @labels = current_shop.labels.active

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @labels }
    end
  end

  # GET /merchants/labels/new
  # GET /merchants/labels/new.json
  def new
    @label = Label.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @label }
    end
  end

  # GET /merchants/labels/1/edit
  def edit
    @label = current_shop.labels.find(params[:id])
  end

  # POST /merchants/labels
  # POST /merchants/labels.json
  def create
    @label = current_shop.labels.new(params[:label])

    respond_to do |format|
      if @label.save
        format.html { redirect_to merchants_labels_path, notice: 'Label was successfully created.' }
        format.json { render json: @label, status: :created, location: @merchants_label }
      else
        format.html { render action: "new" }
        format.json { render json: @label.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /merchants/labels/1
  # PUT /merchants/labels/1.json
  def update
    @label = current_shop.labels.find(params[:id])

    respond_to do |format|
      if @label.update_attributes(params[:label])
        format.html { redirect_to merchants_labels_path, notice: 'Label was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @label.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /merchants/labels/1
  # DELETE /merchants/labels/1.json
  def destroy
    @label = current_shop.labels.find(params[:id])
    @label.destroy

    respond_to do |format|
      format.html { redirect_to merchants_labels_path }
      format.json { head :no_content }
    end
  end
end
