describe Fastlane::Actions::TestProjectAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The test_project plugin is working!")

      Fastlane::Actions::TestProjectAction.run(nil)
    end
  end
end
