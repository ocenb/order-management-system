module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_token!

      private

      def authenticate_api_token!
        auth_header = request.headers["Authorization"].to_s
        scheme, token = auth_header.split(" ", 2)

        valid = scheme == "Bearer" && token.present? &&
          ApiToken.active.exists?(token_digest: ApiToken.digest(token))

        return if valid

        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end
  end
end
