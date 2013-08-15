# Add the stripe plans
Plan.create(plan_id: '1', interval: 'month', name: 'starter', amount: 0, currency: 'usd', min: 0, max: 100)
Plan.create(plan_id: '2', interval: 'month', name: '20pm', amount: 20, currency: 'usd', min: 101, max: 1000)
Plan.create(plan_id: '3', interval: 'month', name: '49pm', amount: 49, currency: 'usd', min: 1001, max: 2500)
Plan.create(plan_id: '4', interval: 'month', name: '79pm', amount: 79, currency: 'usd', min: 2501, max: 5000)
Plan.create(plan_id: '5', interval: 'month', name: '99pm', amount: 99, currency: 'usd', min: 5001, max: 10000)
Plan.create(plan_id: '6', interval: 'month', name: '149pm', amount: 149, currency: 'usd', min: 10001, max: 15000)
Plan.create(plan_id: '7', interval: 'month', name: '179pm', amount: 179, currency: 'usd', min: 15001, max: 20000)
Plan.create(plan_id: '8', interval: 'month', name: '199pm', amount: 199, currency: 'usd', min: 20001, max: 25000)