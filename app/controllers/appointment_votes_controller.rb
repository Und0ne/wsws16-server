class AppointmentVotesController < ApplicationController
  before_action :set_appointment_vote, only: [:show, :edit, :update, :destroy]
  before_action :authenticate, only: [:update, :destroy]

  # GET /appointment_votes
  # GET /appointment_votes.json
  def index
    @appointment_votes = AppointmentVote.all
  end

  # GET /appointment_votes/1/edit
  def edit
  end

  # POST /appointment_votes
  # POST /appointment_votes.json
  def create
    user = User.create(username: params[:username])
    appointment = Appointment.find_by_id!(params[:appointment_id])
    
    @appointment_vote = AppointmentVote.create(user: user, appointment: appointment)

    appointment.appointment_times.each do |appointment_time|
      state = if params[:choices].include? appointment_time.id then "yes" else "no" end
      vote = AppointmentTimeVote.create(appointment_time: appointment_time, state: state)
      @appointment_vote.appointment_time_votes << vote
    end

    respond_to do |format|
      if @appointment_vote.save
        format.html { redirect_to @appointment_vote, notice: 'Appointment vote was successfully created.' }
        format.json { render :show, status: :created, location: @appointment_vote }
      else
        format.html { render :new }
        format.json { render json: @appointment_vote.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /appointment_votes/1
  # PATCH/PUT /appointment_votes/1.json
  def update
    respond_to do |format|
      if @appointment_vote.update(appointment_vote_params)
        format.html { redirect_to @appointment_vote, notice: 'Appointment vote was successfully updated.' }
        format.json { render :show, status: :ok, location: @appointment_vote }
      else
        format.html { render :edit }
        format.json { render json: @appointment_vote.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /appointment_votes/1
  # DELETE /appointment_votes/1.json
  def destroy
    @appointment_vote.destroy
    respond_to do |format|
      format.html { redirect_to appointment_votes_url, notice: 'Appointment vote was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_appointment_vote
      @appointment_vote = AppointmentVote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def appointment_vote_params
      params.require(:appointment_vote).permit(:state, :appointment_id, :user_id)
    end
    
    def authenticate
      authenticate_or_request_with_http_token do |token, options|
        AppointmentVote.find_by(auth_token: token)
      end
    end
end