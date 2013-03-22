require 'spec_helper'

describe "interests/edit" do
  before(:each) do
    @interest = assign(:interest, stub_model(Interest,
      :type_id => 1,
      :type => "",
      :industry_id => 1
    ))
  end

  it "renders the edit interest form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", interest_path(@interest), "post" do
      assert_select "input#interest_type_id[name=?]", "interest[type_id]"
      assert_select "input#interest_type[name=?]", "interest[type]"
      assert_select "input#interest_industry_id[name=?]", "interest[industry_id]"
    end
  end
end
