defmodule ChargeData do
  defstruct [
    :customer,
    :amount,
    id: nil,
    bar_code: nil,
    line: nil,
    due_date: nil,
    issue_date: nil,
    overdue_limit: nil,
    fine: nil,
    interest: nil,
    tags: [],
    descriptions: []
  ]
end
