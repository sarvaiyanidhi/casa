class Users::PasswordsController < Devise::PasswordsController
  include ApplicationHelper
  include PhoneNumberHelper
  include SmsBodyHelper

  def create
    @email, @phone_number = [params[resource_name][:email], params[resource_name][:phone_number]]
    @resource = @email.blank? ? User.find_by(phone_number: @phone_number) : User.find_by(email: @email)

    if valid_params?(@email, @phone_number)
      send_password_reset_mail if email?
      send_password_reset_sms if phone_number?
    else
      respond_with(@resource) # re-render and display any errors
      return
    end
    redirect_to after_sending_reset_password_instructions_path_for(resource_name), notice: "You will receive an email or SMS with instructions on how to reset your password in a few minutes."
  end

  private

  def send_password_reset_mail
    @reset_token = @resource.send_reset_password_instructions # generate a reset token and call devise mailer
  end

  def send_password_reset_sms
    # for case where user enters ONLY a phone number, generate a new reset token to use;
    # otherwise, use the same reset token as sent by devise mailer
    @reset_token ||= @resource.generate_password_reset_token

    create_short_url
    twilio_service = TwilioService.new(@resource.casa_org.twilio_api_key_sid, @resource.casa_org.twilio_api_key_secret, @resource.casa_org.twilio_account_sid)
    sms_params = {
      From: @resource.casa_org.twilio_phone_number,
      Body: password_reset_msg(@resource.display_name, @short_io_service.short_url),
      To: @phone_number
    }
    twilio_service.send_sms(sms_params)
  end

  def valid_params?(email, phone_number)
    return no_user_found_error unless user_exists
    return empty_fields_error if params_not_present(email, phone_number)

    valid_phone_number, error_message = valid_phone_number(phone_number)
    return invalid_phone_number_error(error_message) unless valid_phone_number

    true
  end

  def email?
    !@email.blank?
  end

  def phone_number?
    !@phone_number.blank?
  end

  def empty_fields_error
    @resource.errors.add(:base, "Please enter at least one field.")

    false
  end

  def invalid_phone_number_error(error_message)
    @resource.errors.add(:phone_number, error_message)

    false
  end

  def params_not_present(email, phone_number)
    email.blank? && phone_number.blank?
  end

  def user_exists
    !@resource.nil?
  end

  def no_user_found_error
    resource.errors.add(:base, "User does not exist.")

    false
  end

  def create_short_url
    @short_io_service = ShortUrlService.new
    @short_io_service.create_short_url(request.base_url + "/users/password/edit?reset_password_token=#{@reset_token}")
  end
end
