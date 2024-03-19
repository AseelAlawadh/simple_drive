module RequestHelpers
    def token_for_user(user)
      JWT.encode({ user_id: user.id }, ENV['JWT_SECRET_KEY'], 'HS256')
    end
  def json_response
    JSON.parse(response.body)
  end
end