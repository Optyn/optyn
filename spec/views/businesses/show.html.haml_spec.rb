require 'spec_helper'

describe "businesses/show" do
  before(:each) do
    @business = assign(:business, stub_model(Business,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
  end
end
