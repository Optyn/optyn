require 'spec_helper'

describe "interests/show" do
  before(:each) do
    @interest = assign(:interest, stub_model(Interest,
      :type_id => 1,
      :type => "Type",
      :industry_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Type/)
    rendered.should match(/2/)
  end
end
