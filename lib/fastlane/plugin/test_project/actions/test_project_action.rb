require 'fastlane/action'
require_relative '../helper/test_project_helper'
require 'json'

module Fastlane
  module Actions
    class TestProjectAction < Action
      module SharedValues
        TESTPROJECT_API_TOKEN = :TESTPROJECT_API_TOKEN
        TESTPROJECT_PROJECT_ID = :TESTPROJECT_PROJECT_ID
        TESTPROJECT_APP_ID = :TESTPROJECT_APP_ID
        TESTPROJECT_FILE_NAME = :TESTPROJECT_FILE_NAME
        IPA_OUTPUT_PATH = :IPA_OUTPUT_PATH
      end

      def self.run(params)
        project_id = params[:project_id]
        app_id = params[:app_id]
        api_token = params[:api_token]
        file_name = params[:file_name]
        ipa_path = params[:ipa_path]

        upload_url = Helper::TestProjectHelper.retrieve_upload_url(api_token, app_id, project_id)
        Helper::TestProjectHelper.upload_ipa(ipa_path, upload_url)
        Helper::TestProjectHelper.confirm_upload_and_name_file(api_token, app_id, project_id, file_name)

        UI.message("Test Project Upload Completed!")
      end

      def self.description
        "Upload an iOS ipa to Test Project for automation testing: https://testproject.io"
      end

      def self.authors
        ["rlester"]
      end

      def self.return_value
      end

      def self.details
        """
        Upload the provided iPA to Test Project for automated testing.

        Instructions for retrieving API key, project id, and app id can be found here:
        https://docs.testproject.io/tips-and-tricks/extending-testproject-recorder-capabilities-for-dedicated-elements
        """
      end
      1
      def self.available_options
        [
            FastlaneCore::ConfigItem.new(key: :api_token,
                                         env_name: "TESTPROJECT_API_TOKEN",
                                         description: "API Token for TestProject",
                                         default_value: Actions.lane_context[SharedValues::TESTPROJECT_API_TOKEN],
                                         optional: false,
                                         type: String,
                                         verify_block: proc do |value|
                                           UI.user_error!("No API token for TestProject given, pass using `api_token: 'token'`") unless value && !value.empty?
                                         end),
            FastlaneCore::ConfigItem.new(key: :project_id,
                                         env_name: "TESTPROJECT_PROJECT_ID",
                                         description: "The project id can be found in the URL when viewing the project in TestProject",
                                         default_value: Actions.lane_context[SharedValues::TESTPROJECT_PROJECT_ID],
                                         optional: false,
                                         type: String,
                                         verify_block: proc do |value|
                                           UI.user_error!("No Project ID given") unless value && !value.empty?
                                         end),
            FastlaneCore::ConfigItem.new(key: :app_id,
                                         env_name: "TESTPROJECT_APP_ID",
                                         description: "The app id can be found in the URL when viewing the app in TestProject",
                                         default_value: Actions.lane_context[SharedValues::TESTPROJECT_APP_ID],
                                         optional: false,
                                         type: String,
                                         verify_block: proc do |value|
                                           UI.user_error!("No APP ID given") unless value && !value.empty?
                                         end),
            FastlaneCore::ConfigItem.new(key: :file_name,
                                         env_name: "TESTPROJECT_FILE_NAME",
                                         description: "The file name that will be used in Test Project",
                                         default_value: Actions.lane_context[SharedValues::TESTPROJECT_FILE_NAME],
                                         optional: false,
                                         type: String,
                                         verify_block: proc do |value|
                                           UI.user_error!("No file name given") unless value && !value.empty?
                                         end),
            FastlaneCore::ConfigItem.new(key: :ipa_path,
                                         env_name: "IPA_OUTPUT_PATH",
                                         description: "Build path for iOS builds",
                                         default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                         optional: false,
                                         type: String,
                                         verify_block: proc do |value|
                                           accepted_formats = [".ipa"]
                                           self.optional_error("Only \".ipa\" formats are allowed, you provided \"#{File.extname(value)}\"") unless accepted_formats.include? File.extname(value)
                                         end),
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        [:ios].include?(platform)
        true
      end
    end
  end
end
