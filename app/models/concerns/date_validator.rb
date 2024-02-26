class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    unless value.is_a?(Date) || value.is_a?(Time)
      record.errors.add(attribute, "must be a valid date")
    end
  rescue ArgumentError
    record.errors.add(attribute, "must be a valid date")
  end
end

# class Event < ApplicationRecord
#   # Using the custom validator
#   validates :start_date, date: true
# end
