require 'spec_helper'

describe PufferPages::Liquid::Tags::Image do
  describe 'snippet' do
    let!(:root) { Fabricate :root }

    specify { root.render("{% image 'img.png' %}").should == "<%= image_tag 'img.png', {} %>" }
    specify { root.render("{% image 'img.png', alt:'alttext' %}").should == "<%= image_tag 'img.png', {\"alt\"=>\"alttext\"} %>" }
  end
end
