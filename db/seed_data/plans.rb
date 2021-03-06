# Add the stripe plans
Plan.create(plan_id: '1', interval: 'month', name: 'starter', amount: 0, currency: 'usd', min: 0, max: 100)
Plan.create(plan_id: '2', interval: 'month', name: '20pm', amount: 2000, currency: 'usd', min: 101, max: 1000)
Plan.create(plan_id: '3', interval: 'month', name: '49pm', amount: 4900, currency: 'usd', min: 1001, max: 2500)
Plan.create(plan_id: '4', interval: 'month', name: '79pm', amount: 7900, currency: 'usd', min: 2501, max: 5000)
Plan.create(plan_id: '5', interval: 'month', name: '99pm', amount: 9900, currency: 'usd', min: 5001, max: 10000)
Plan.create(plan_id: '6', interval: 'month', name: '149pm', amount: 14900, currency: 'usd', min: 10001, max: 15000)
Plan.create(plan_id: '7', interval: 'month', name: '179pm', amount: 17900, currency: 'usd', min: 15001, max: 20000)
Plan.create(plan_id: '8', interval: 'month', name: '199pm', amount: 19900, currency: 'usd', min: 20001, max: 25000)
Plan.create(plan_id: '9', interval: 'month', name: '225pm', amount: 22500, currency: 'usd', min: 25001, max: 50000)
Plan.create(plan_id: '10', interval: 'month', name: '250pm', amount: 25000, currency: 'usd', min: 50001, max: 100000)
Plan.create(plan_id: '11', interval: 'month', name: '300pm', amount: 30000, currency: 'usd', min: 100001, max: 150000)
Plan.create(plan_id: '12', interval: 'month', name: '350pm', amount: 35000, currency: 'usd', min: 150001, max: 200000)
Plan.create(plan_id: '13', interval: 'month', name: '399pm', amount: 39900, currency: 'usd', min: 200001, max: 250000)
Plan.create(plan_id: '14', interval: 'month', name: '450pm', amount: 45000, currency: 'usd', min: 250001, max: 300000)
Plan.create(plan_id: '15', interval: 'month', name: '500pm', amount: 50000, currency: 'usd', min: 300001, max: 400000)
Plan.create(plan_id: '16', interval: 'month', name: '550pm', amount: 55000, currency: 'usd', min: 400001, max: 500000)
Plan.create(plan_id: '17', interval: 'month', name: '750pm', amount: 75000, currency: 'usd', min: 500001, max: 750000)
Plan.create(plan_id: '18', interval: 'month', name: '999pm', amount: 99900, currency: 'usd', min: 750001, max: 999999)