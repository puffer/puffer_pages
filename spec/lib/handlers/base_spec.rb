require 'spec_helper'

describe PufferPages::Handlers::Base do
  subject { described_class.new(:html) }
  let(:page_part) { Fabricate :main, body: 'just {{type}}' }

  context do
    specify { subject.process(page_part, drops: { type: 'plain html' }).should == 'just plain html' }
  end
end
