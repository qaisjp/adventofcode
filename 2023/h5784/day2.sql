select
    c.name, c.phone, o.customerid, o.ordered, o.shipped
from
    orders o, customers c, orders_items oi
where
    -- in 2017
    o.ordered like '2017%' and

    -- get the initials
    o.customerid = c.customerid and
    substr(c.name, 1, 1) = 'J' and
    substr(c.name, instr(c.name, ' ')+1, 1) = 'P'

    -- for the rug cleaner sku (sku found by cmd-fing noahs-orders_items.csv)
    and oi.orderid = o.orderid
    and sku = 'HOM2761';

-- 332-274-4185