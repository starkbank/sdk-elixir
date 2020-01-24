defmodule ChargeData do
  defstruct [
    :customer_id,
    :amount,
    due_date: nil,
    fine: nil,
    interest: nil,
    overdue_limit: nil,
    tags: [],
    descriptions: []
  ]
end
