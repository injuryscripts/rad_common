module RadCommonCompany
  extend ActiveSupport::Concern

  private

    def check_model(model)
      problems = []
      model.find_each { |record| validate_record(record, problems) }
      problems
    end

    def check_query_records(query)
      problems = []
      records = query.call
      records.find_each { |record| validate_record(record, problems) }
      problems
    end

    def validate_record(record, error_messages_array)
      record.bypass_geocoding = true if record.respond_to?(:bypass_geocoding)

      unless record.valid?
        messages = record.errors.full_messages

        supressions = Rails.application.config.global_validity_supress || []
        supression = supressions.select {|item| item[:class] == record.class.to_s }.first

        if supression
          messages = messages - supression[:messages]
        end

        if messages.any?
          error_messages_array.push([record, "#{messages.join(', ')}"])
        end
      end
    end
end
