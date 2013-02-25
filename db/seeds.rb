# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Plan.create(:name=>"Pro",:plan_id=>'pro',:amount=>10000,:interval=>"month",:currency=>"usd")
Plan.create(:plan_id=>"advanced",:interval=>"month",:name=>"Advanced",:amount=>5000,:currency=>"usd")
Plan.create(:plan_id=>"standard",:interval=>"month",:name=>"Standard",:amount=>2500,:currency=>"usd")
Plan.create(:plan_id=>"starter",:interval=>"month",:name=>"Starter",:amount=>1000,:currency=>"usd")
Plan.create(:plan_id=>"lite",:interval=>"month",:name=>"Lite",:amount=>500,:currency=>"usd")