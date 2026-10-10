class WellKnownController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def apple_app_site_association
    team_id = ENV.fetch("APPLE_TEAM_ID", "YOUR_TEAM_ID")
    bundle_id = "et.netale.LitLoop"

    render json: {
      applinks: {
        apps: [],
        details: [
          {
            appID: "#{team_id}.#{bundle_id}",
            paths: [ "*" ],
            components: [
              {
                "/": "/*",
                comment: "Matches all routes on litloop.club"
              }
            ]
          }
        ]
      },
      webcredentials: {
        apps: [
          "#{team_id}.#{bundle_id}"
        ]
      }
    }, content_type: "application/json"
  end

  def assetlinks
    default_fingerprint = "14:6D:E9:7F:69:80:C2:79:47:37:7A:B0:21:42:9E:E8:DE:C5:27:26:5B:72:36:54:9A:39:B2:BC:23:46:18:45"
    configured_fingerprints = ENV["ANDROID_SHA256_FINGERPRINTS"]&.split(",")&.map(&:strip) || [ default_fingerprint ]

    render json: [
      {
        relation: [ "delegate_permission/common.handle_all_urls" ],
        target: {
          namespace: "android_app",
          package_name: "et.netale.litloop",
          sha256_cert_fingerprints: configured_fingerprints
        }
      }
    ], content_type: "application/json"
  end
end
