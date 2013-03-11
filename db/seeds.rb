# Add the stripe plans
Plan.create(plan_id: 'pro', interval: 'month', name: 'Pro', amount: 10000,  currency: 'usd')
Plan.create(plan_id: 'advanced', interval: 'month', name: 'Advanced', amount: 5000, currency: 'usd')
Plan.create(plan_id: 'standard', interval: 'month', name: 'Standard', amount: 2500, currency: 'usd')
Plan.create(plan_id: 'starter', interval: 'month', name: 'Starter', amount: 1000,currency: 'usd')
Plan.create(plan_id: 'lite', interval: 'month', name: 'Lite', amount: 500, currency: 'usd')