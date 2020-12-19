class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room, only: %i[show edit update destroy start_session generate_token join_session recorded_session start_archive delete_archive stop_archive]
  before_action :set_opentok, only: %i[show create recorded_session start_session generate_token join_session start_archive delete_archive stop_archive]

  def index
    @rooms = Room.all
  end

  def show; end

  def start_session
    @token = generate_token
  end

  def join_session
    @token = generate_token
  end

  def start_archive
    archive = @opentok.archives.create @room.vonage_session_id, name: @room.name
    @room.archive_id = archive.id
    @room.save
  end

  def stop_archive
    @opentok.archives.stop_by_id @room.archive_id
  end

  def delete_archive
    @opentok.archives.delete_by_id @room.archive_id
    redirect_to root_path, notice: 'Archive was successfully deleted.'
  end

  def recorded_session
    @archive = @opentok.archives.find @room.archive_id
    redirect_to @archive&.url
  end

  def new
    @room = Room.new
  end

  def edit; end

  def create
    @room = Room.new(room_params)
    session = @opentok.create_session media_mode: :routed
    @room.update(vonage_session_id: session.session_id)
    respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: 'Room was successfully created.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to @room, notice: 'Room was successfully updated.' }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @room.destroy
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_opentok
    @api_key = '47001474'
    @api_secret = 'd8cb7942d6ce558196e6af111703ce7a9420de33'
    @opentok = OpenTok::OpenTok.new @api_key, @api_secret
  end

  def generate_token
    @opentok.generate_token @room.vonage_session_id
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_room
    @room = Room.find(params[:id] || params[:room_id])
  end

  # Only allow a list of trusted parameters through.
  def room_params
    params.require(:room).permit(:name, :vonage_session_id)
  end
end
