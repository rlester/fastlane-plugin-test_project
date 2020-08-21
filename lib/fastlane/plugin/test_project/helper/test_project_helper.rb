require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class TestProjectHelper
      # Confirm the file upload and provide the name for the file.
      def self.confirm_upload_and_name_file(api_token, app_id, project_id, file_name)
        UI.message("Confirming Upload and Naming Uploaded File #{file_name}")
        encoded_url = URI.encode("https://api.testproject.io/v2/projects/#{project_id}/applications/#{app_id}/file")
        uri = URI.parse(encoded_url)
        request = Net::HTTP::Post.new(uri)
        request.content_type = 'application/json'
        request['Authorization'] = api_token
        request.body = JSON.dump({
                                     "fileName": file_name,
                                 })

        req_options = {
            use_ssl: uri.scheme == "https",
        }

        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end

        unless response.is_a?(Net::HTTPSuccess)
          UI.user_error!("Code: #{response.code} - Message: #{response.message}")
        end
        UI.message("File Confirmed")
      end

      # Steam the IPA to the provided URL.
      # *Note: I was unable to get this working within ruby. Would rather have a ruby implementation but this works for now.
      def self.upload_ipa(ipa_path, upload_url)
        UI.message("Uploading IPA to Test Project... This may take a few moments.")
        puts upload_url
        curl = "curl -v -X PUT --header \"Content-Type:application/octet-stream\" --data-binary @#{ipa_path} \"#{upload_url}\""
        Kernel.system curl
        UI.message("IPA Uploaded to Test Project")
      end

      # Retrive the URL we need to use to upload the IPA.
      def self.retrieve_upload_url(api_token, app_id, project_id)
        UI.message("Retrieving Upload URL...")
        encoded_url = URI.encode("https://api.testproject.io/v2/projects/#{project_id}/applications/#{app_id}/file/upload-link")
        uri = URI.parse(encoded_url)
        request = Net::HTTP::Get.new(uri)
        request.content_type = 'application/json'
        request['Authorization'] = api_token

        req_options = {
            use_ssl: uri.scheme == "https",
        }

        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end

        unless response.is_a?(Net::HTTPSuccess)
          UI.user_error!("Code: #{response.code} - Message: #{response.message}")
        end

        UI.message("Upload URL Retrieved.")
        parsed_json = JSON.parse(response.body)
        parsed_json["url"]
      end
    end
  end
end
