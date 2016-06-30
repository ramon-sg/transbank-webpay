require 'spec_helper'

RSpec.describe Transbank::Webpay::Helper do
  let(:subject) { Object.new.extend described_class }

  describe '#camelcase' do
    it { expect(subject.camelcase('user_id')).to eq('userId') }
    it { expect(subject.camelcase(:user_id)).to eq('userId') }
    it { expect(subject.camelcase(:user)).to eq('user') }
  end
end
