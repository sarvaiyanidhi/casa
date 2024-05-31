class VolunteerParameters < UserParameters
  include PhoneNumberHelper

  def initialize(params)
    params[:volunteer][:phone_number] = strip_unnecessary_characters(params[:volunteer][:phone_number])

    super(params, :volunteer)
  end
end
