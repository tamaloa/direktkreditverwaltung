module ParamsToDate
  extend ActiveSupport::Concern

  def date_select_params_to_date(date_params, attribute)
    return nil unless date_params
    return nil if date_params.empty?

    begin
      return Date.civil(date_params["#{attribute}(1i)"].to_i,
                        date_params["#{attribute}(2i)"].to_i,
                        date_params["#{attribute}(3i)"].to_i)
    rescue ArgumentError
      return nil
    end
  end

end