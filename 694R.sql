select count (*)
from fctemp.TMP_COE_ORDER_LINES ol
where ol.RETURN_ORDER_NUMBER is not null
or ol.REFERENCE_ORDER_LINE_ID is not null


select ol.order_number, cu.customer_number, ol.return_order_number, ol.creation_date, ol.shipped_quantity, ol.unit_selling_price, ol.unit_tax_amount
from frc.COE_ORDER_LINES@rcom.world ol, frc.coe_customers@rcom.world cu
where ol.RETURN_ORDER_NUMBER is not null
and ol.customer_id = cu.customer_id
AND ol.creation_date BETWEEN UPPER('21-OCT-02') AND UPPER('31-OCT-02')
--  AND ol.creation_date BETWEEN UPPER('01-NOV-02') AND UPPER('30-NOV-02')
--  AND ol.creation_date BETWEEN UPPER('01-DEC-02') AND UPPER('31-DEC-02')
--  AND ol.creation_date BETWEEN UPPER('01-JAN-03') AND UPPER('31-JAN-03')
--  AND ol.creation_date BETWEEN UPPER('01-FEB-03') AND UPPER('28-FEB-03')
--  AND ol.creation_date BETWEEN UPPER('01-MAR-03') AND UPPER('05-APR-03')
;
