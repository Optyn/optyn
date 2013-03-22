require 'spec_helper'

describe "businesses/index" do
  before(:each) do
    assign(:businesses, [
      stub_model(Business,
        :name => "Name"
      ),
      stub_model(Business,
        :name => "Name"
      )
    ])
  end

  it "renders a list of businesses" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
