describe Fastlane::Actions::XamarinAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The xamarin plugin is working!")

      Fastlane::Actions::XamarinAction.run(nil)
    end
  end
end
