require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Maven do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ maven }).should.be.instance_of Command::Maven
      end
    end
  end
end

