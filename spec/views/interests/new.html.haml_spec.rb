require 'spec_helper'

describe "interests/new" do
  before(:each) do
    assign(:interest, stub_model(Interest,
      :type_id => 1,
      :type => "",
      :industry_id => 1
    ).as_new_record)
  end

  it "renders new interest form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", interests_path, "post" do
      assert_select "input#interest_type_id[name=?]", "interest[type_id]"
      assert_select "input#interest_type[name=?]", "interest[type]"
      assert_select "input#interest_industry_id[name=?]", "interest[industry_id]"
    end
  end
end
