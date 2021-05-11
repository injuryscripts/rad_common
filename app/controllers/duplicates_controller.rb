class DuplicatesController < ApplicationController
  def index
    skip_policy_scope

    @model = model
    @record = gather_record

    if @record.nil?
      skip_authorization
      flash[:success] = 'Congratulations, there are no more duplicates found!'
      redirect_to root_path
      return
    end

    authorize @record, :index_duplicates?

    @records = []
    @duplicates_count = model.relevant_duplicates.count

    @records = @record.duplicates
    return if @records.count.positive?

    @record.process_duplicates

    flash[:error] = "Invalid #{model.to_s.downcase} data, perhaps something has changed or another user has "\
                    'resolved these duplicates.'

    redirect_to root_path
  end

  def merge
    @record = model.find_by(id: params[:id])
    authorize @record, :merge_duplicates?

    if params[:merge_data]
      MergeDuplicatesJob.perform_later(params[:merge_data].keys, @record.class.to_s, @record.id, current_user.id)

      flash[:success] = "The duplicates are processing, we'll email you when complete."
      redirect_to index_path
    else
      flash[:error] = 'Missing parameters'
      redirect_back(fallback_location: root_path)
    end
  end

  def not
    @record = model.find_by(id: params[:id])
    authorize @record, :not_duplicate?
    other_record = model.find_by(id: params[:master_record])

    if other_record # else it's no longer there, moot point
      if policy(other_record).destroy?
        @record.not_duplicate(other_record)
      else
        flash[:error] = 'You do not have authorization to modify this record.'
        redirect_to index_path
        return
      end
    end

    message = 'The record was marked as not a duplicate.'

    email_options = { email_action: { message: 'Click here to view the details.',
                                      button_text: 'View',
                                      button_url: url_for(@record) } }

    # TODO: remove this once done monitoring
    RadbearMailer.simple_message('gary@radicalbear.com', message, message, email_options).deliver_later

    flash[:success] = message
    redirect_to index_path
  end

  def do_later
    @record = model.find_by(id: params[:id])
    authorize @record, :duplicate_do_later?

    max = Duplicate.where(duplicatable_type: model.name).maximum(:sort)
    sort = (max ? max + 1 : 1)
    @record.create_or_update_metadata! sort: sort

    if @record.duplicate.present? && @record.duplicate.score.present?
      dupes = @record.duplicates

      if dupes.count == 1
        record = dupes.first[:record]
        record.create_or_update_metadata! sort: sort
      end
    end

    flash[:notice] = "#{model} was successfully updated."
    redirect_to index_path
  end

  def reset
    @record = model.find_by(id: params[:id])
    authorize @record, :reset_duplicates?

    @record.reset_duplicates
    redirect_to @record
  end

  private

    def index_path
      "/rad_common/duplicates?model=#{model}"
    end

    def gather_record
      if params[:id].present?
        @model.relevant_duplicates.where(id: params[:id]).first
      else
        @model.relevant_duplicates.order(sort: :asc, score: :desc, updated_at: :desc, id: :desc).limit(1).first
      end
    end

    def model
      Object.const_get params[:model]
    end
end