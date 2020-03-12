defmodule StarkBank.Charge.Structs.ChargeData do
  @doc """
  Holds data from a single charge

  Parameters:
  - customer [StarkBank.Charge.Structs.CustomerData]: charge customer data;
  - amount [int]: total charged amount in cents, e.g.: 150000 (= R$1.500,00);
  - id [string]: charge unique ID, e.g.: "5730684534521856";
  - bar_code [string]: charge bar code, e.g.: "34198777500000500001090000788367307144464000";
  - line [string]: charge line number, e.g.: "34191.09008 00788.367308 71444.640008 8 77750000050000";
  - due_date [timestamp as string]: charge due date, e.g.: "2019-01-21T01:59:59.999999+00:00";
  - issue_date [timestamp as string]: charge issue date, e.g.: "2018-12-29T20:05:33.812908+00:00";
  - overdue_limit [int]: number of days after due date when the charge will expire, 0<= n <= 59, e.g.: 5;
  - fine [float]: percentage of the charge amount to be charged if paid after due date, e.g.: 2.00 (= 2%);
  - interest [float]: monthly interest, in percentage, charged if paid after due date, e.g.: 1.50 (= 1.5%);
  - discount [float]: defines the discount percentage applicable if charge is paid before discount_date (if discount is defined, discountDate must also be defined)
  - discount_date [date or string ("%Y-%m-%d")]: defines limit date until when the defined discount will be valid (if discount is defined, discountDate must also be defined)
  - status [string]: charge status, e.g.: created, registered, paid, overdue, canceled, failed;
  - tags [list of strings]: custom tags used when searching charges, e.g.: ["client1", "cash-in"];
  - workspace_id [strings]: workspace_id that created the charge, e.g.: "5078376503050240";
  - descriptions [list of StarkBank.Charge.Structs.ChargeDescriptionData]: list of charge descriptions;
  """
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
    discount: nil,
    discount_date: nil,
    status: nil,
    workspace_id: nil,
    tags: [],
    descriptions: []
  ]
end
