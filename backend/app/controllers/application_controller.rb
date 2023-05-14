class ApplicationController < ActionController::API
  private

  # Renders a JSON API formatted error response.
  # @param status [Integer] the HTTP status code for the error
  # @param detail [String] a human-readable explanation specific to this occurrence of the problem
  def render_error(status, detail)
    render json: {
      errors: [
        {
          status: status.to_s,
          title: Rack::Utils::HTTP_STATUS_CODES[status],
          detail: detail
        }
      ]
    }, status: status
  end

  # Renders a JSON API formatted error response for validation errors.
  # @param record [ActiveRecord::Base] an instance of an ActiveRecord model with validation errors
  def render_validation_errors(record)
    render json: {
      errors: record.errors.messages.map do |field, messages|
        messages.map do |message|
          {
            status: '422',
            title: 'Unprocessable Entity',
            detail: "#{field.to_s} #{message}",
            source: field
          }
        end
      end.flatten
    }, status: :unprocessable_entity
  end
end
