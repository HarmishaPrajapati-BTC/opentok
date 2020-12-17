class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room, only: %i[show edit update destroy recorded_session start_archive delete_archive stop_archive]
  before_action :set_opentok, only: %i[show recorded_session start_archive delete_archive stop_archive]

  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = Room.all
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    @token = @opentok.generate_token @room.vonage_session_id, { name: current_user.name }
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

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit; end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(room_params)

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

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
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

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room.destroy
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_opentok
    tries = 5
    begin
      @opentok = OpenTok::OpenTok.new('47001474', 'd8cb7942d6ce558196e6af111703ce7a9420de33')
      logger.debug 'opentok connected.'
    rescue Errno::ETIMEDOUT => e
      log.error e
      tries -= 1
      if tries.positive?
        logger.debug 'retrying opentok.new...'
        retry
      else
        logger.debug 'opentok.new timed out...'
        puts "ERROR: #{e.message}"
      end
    end
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
