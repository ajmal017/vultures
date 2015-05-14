Fabricator(:hist_data) do
  cid { Faker::Company.ein }
  period {"2012-12-31"}
  market_cap { 500.1 }
  roc { 0.1 }
  earnings_yield { 0.15 }
  price { 30.05 }
end
