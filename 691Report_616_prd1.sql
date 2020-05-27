

-----Original Message-----
--From: Chakri Adimulam 
--Sent: Friday, June 20, 2003 10:32 AM
--To: LeAnn Cole; MikkelHylden_EDS (E-mail)
--Cc: Clayton Royal; BrianMcavoy_EDS (E-mail); Brian A Gatz (E-mail)
--Subject: SQL for P-log 691-- Missing Payments, Credits, and Adjustments
--
--Mikkel/LeAnn,
--
--Here is the latest copy of the SQL for P-log 691 (Missing Payments, Credits, and Adjustments) report.
--
--thanks
--Chakri
--





SELECT  asa.display_code				   "RCOM_ACTIVITY_SOURCE_CODE",
	'PAYMENTS'					   "APPLICATION_TYPE",
	cust.customer_number                               "CUSTOMER_NUMBER",
        op.order_number                                    "ORDER_NUMBER",
        'n/a' 						   "RECEIPT_NUMBER",
        pmi.display_code				   "PAYMENT_OR_ADJ_TYPE",
        max(TO_CHAR(op.payment_authorized_date,'mm/dd/yyyy'))	"AUTHORIZED_DATE",
        max(TO_CHAR(op.deposited_date,'mm/dd/yyyy'))		"DEPOSITED_DATE",
        max(TO_CHAR(op.payment_settled_date,'mm/dd/yyyy'))	"SETTLED_DATE",
        max(TO_CHAR(op.denied_date,'mm/dd/yyyy'))		"FAILED_DATE",
        sum(op.payment_amount)                             "RCOM_PAYMENT_AMOUNT",
        ART.AR_RCPT_TOTAL_AMOUNT                           "AR_PAYMENT_AMOUNT",
        (ART.AR_RCPT_TOTAL_AMOUNT - sum(op.payment_amount)) "AR_RCOM_DIFFERENCE",
        0						    "ADJ_AMOUNT",
        0						    "CR_AMOUNT",
        0						    "FAILED_PAYMENT",
        'n/a'						    "INTERFACE_BATCH",
        'ORDER_AND_RECEIPT_IN_AR'                           "COMMENTS"
FROM    TMP_COE_ORDER_PAYMENTS op, TMP_COE_CUSTOMERS cust, TMP_COE_PAYMENT_METHODS_A pmi, 
		tmp_coe_activity_sources_a asa, TMP_coe_orders o
        , (SELECT HCA.ACCOUNT_NUMBER CUSTOMER_NUMBER, ARC.ATTRIBUTE10 ORDER_NUMBER
                , ARC.ATTRIBUTE11 PAYMENT_TYPE, SUM(ARC.AMOUNT) AR_RCPT_TOTAL_AMOUNT
           FROM AR_CASH_RECEIPTS_ALL ARC, HZ_CUST_ACCOUNTS HCA
           WHERE ARC.ATTRIBUTE_CATEGORY = 'RCOM_INTERFACE' 
           AND ARC.PAY_FROM_CUSTOMER = HCA.CUST_ACCOUNT_ID
           AND ARC.STATUS IN ('APP', 'UNAPP')
           GROUP BY HCA.ACCOUNT_NUMBER, ARC.ATTRIBUTE10, ARC.ATTRIBUTE11) ART

WHERE   op.payment_settled_date BETWEEN 
                   to_date('&start_date 00:00:00', 'mm/dd/yyyy hh24:mi:ss') AND
                   to_date('&end_date 23:59:59', 'mm/dd/yyyy hh24:mi:ss')
AND	    op.order_id = o.order_id
AND 	asa.activity_source_id = o.activity_source_id
AND     op.payment_settled_status_code = 'S'
AND     op.payment_amount > 0
AND     op.company_id = 4000
AND     op.customer_id = cust.customer_id(+)
AND	op.payment_settled_date > to_date('10/20/2002 00:00:00', 'mm/dd/yyyy hh24:mi:ss')
AND     op.payment_method_id = pmi.payment_method_id
-- the next clause excludes PAYADJ types that should go through the adjustment interface.
AND     (op.adjustment_reason_id != 3123597
         or   op.adjustment_reason_id IS NULL
         or   (op.adjustment_reason_id = 3123597 
               and op.payment_amount > 0
               and op.payment_settled_date > to_date('05/31/2003','mm/dd/yyyy')))
AND     pmi.payment_method_id IN
        (SELECT payment_method_id
         FROM   TMP_COE_PAYMENT_METHODS_A
         WHERE  company_id = 4000
         AND    inactive_flag = 0
         AND    adjustment_flag = 0
        )
AND     pmi.payment_method_id NOT IN 
        (2123682, 2123687, 2123684, 2123686, 2123685, 1026)
 -- above clause excludes UNDER, BPO, HCPO, PIN, and VPO CASH types, respectively
AND OP.ORDER_NUMBER = ART.ORDER_NUMBER
AND CUST.CUSTOMER_NUMBER = ART.CUSTOMER_NUMBER
AND PMI.BASE_CODE = ART.PAYMENT_TYPE
GROUP BY asa.display_code, CUST.CUSTOMER_NUMBER, OP.ORDER_NUMBER, pmi.display_code, ART.AR_RCPT_TOTAL_AMOUNT
HAVING SUM(OP.PAYMENT_AMOUNT) != ART.AR_RCPT_TOTAL_AMOUNT

UNION ALL

SELECT  asa.display_code				   "RCOM_ACTIVITY_SOURCE_CODE",
	'PAYMENTS'					   "APPLICATION_TYPE",
	cust.customer_number                               "CUSTOMER_NUMBER",
        op.order_number                                    "ORDER_NUMBER",
        'n/a' 						   "RECEIPT_NUMBER",
        pmi.display_code				   "PAYMENT_OR_ADJ_TYPE",
        max(TO_CHAR(op.payment_authorized_date,'mm/dd/yyyy'))	"AUTHORIZED_DATE",
        max(TO_CHAR(op.deposited_date,'mm/dd/yyyy'))		"DEPOSITED_DATE",
        max(TO_CHAR(op.payment_settled_date,'mm/dd/yyyy'))	"SETTLED_DATE",
        max(TO_CHAR(op.denied_date,'mm/dd/yyyy'))		"FAILED_DATE",
        sum(op.payment_amount)                             "RCOM_PAYMENT_AMOUNT",
        0                                                  "AR_PAYMENT_AMOUNT",
       (0 - sum(op.payment_amount))                        "AR_RCOM_DIFFERENCE",
        0						   "ADJ_AMOUNT",
        0						   "CR_AMOUNT",
        0						   "FAILED_PAYMENT",
        'n/a'						   "INTERFACE_BATCH",
        'ORDER_NOT_IN_AR'                         	   "COMMENTS"

FROM    TMP_COE_ORDER_PAYMENTS op, TMP_COE_CUSTOMERS cust, TMP_COE_PAYMENT_METHODS_A pmi, 
		tmp_coe_activity_sources_a asa, TMP_coe_orders o
WHERE   op.payment_settled_date BETWEEN 
                   to_date('&start_date 00:00:00', 'mm/dd/yyyy hh24:mi:ss') AND
                   to_date('&end_date 23:59:59', 'mm/dd/yyyy hh24:mi:ss')
AND	    op.order_id = o.order_id
AND 	asa.activity_source_id = o.activity_source_id
AND     op.payment_settled_status_code = 'S'
AND     op.payment_amount > 0
AND     op.company_id = 4000
AND     op.customer_id = cust.customer_id(+)
AND	op.payment_settled_date > to_date('10/20/2002 00:00:00', 'mm/dd/yyyy hh24:mi:ss')
AND     op.payment_method_id = pmi.payment_method_id
-- the next clause excludes PAYADJ types that should go through the adjustment interface.
AND     (op.adjustment_reason_id != 3123597
         or   op.adjustment_reason_id IS NULL
         or   (op.adjustment_reason_id = 3123597 
               and op.payment_amount > 0
               and op.payment_settled_date > to_date('05/31/2003','mm/dd/yyyy')))
AND     pmi.payment_method_id IN
        (SELECT payment_method_id
         FROM   TMP_COE_PAYMENT_METHODS_A
         WHERE  company_id = 4000
         AND    inactive_flag = 0
         AND    adjustment_flag = 0
        )
AND     pmi.payment_method_id NOT IN 
        (2123682, 2123687, 2123684, 2123686, 2123685, 1026)
 -- above clause excludes UNDER, BPO, HCPO, PIN, and VPO, CASH types, respectively
AND NOT EXISTS (SELECT 1 FROM RA_CUSTOMER_TRX_ALL RCT
           WHERE RCT.ATTRIBUTE_CATEGORY = 'RCOM_INTERFACE' 
           AND RCT.BATCH_SOURCE_ID = 1043       -- RCOM_INTERFACE
           AND RCT.ATTRIBUTE2 = OP.ORDER_NUMBER)
GROUP BY asa.display_code, CUST.CUSTOMER_NUMBER, OP.ORDER_NUMBER, pmi.display_code

UNION ALL

SELECT  asa.display_code				   "RCOM_ACTIVITY_SOURCE_CODE",
	'PAYMENTS'					   "APPLICATION_TYPE",
	cust.customer_number                               "CUSTOMER_NUMBER",
        op.order_number                                    "ORDER_NUMBER",
        'n/a' 						   "RECEIPT_NUMBER",
        pmi.display_code				   "PAYMENT_OR_ADJ_TYPE",
        max(TO_CHAR(op.payment_authorized_date,'mm/dd/yyyy'))	"AUTHORIZED_DATE",
        max(TO_CHAR(op.deposited_date,'mm/dd/yyyy'))		"DEPOSITED_DATE",
        max(TO_CHAR(op.payment_settled_date,'mm/dd/yyyy'))	"SETTLED_DATE",
        max(TO_CHAR(op.denied_date,'mm/dd/yyyy'))		"FAILED_DATE",
        sum(op.payment_amount)                             "RCOM_PAYMENT_AMOUNT",
        0                                                  "AR_PAYMENT_AMOUNT",
       (0 - sum(op.payment_amount))                        "AR_RCOM_DIFFERENCE",
        0						   "ADJ_AMOUNT",
        0						   "CR_AMOUNT",
        0						   "FAILED_PAYMENT",
        'n/a'						   "INTERFACE_BATCH",
        'ORDER_IN_AR_BUT_RECEIPT_NOT_IN_AR'                "COMMENTS"

FROM    TMP_COE_ORDER_PAYMENTS op, TMP_COE_CUSTOMERS cust, TMP_COE_PAYMENT_METHODS_A pmi, 
		tmp_coe_activity_sources_a asa, TMP_coe_orders o
WHERE   op.payment_settled_date BETWEEN 
                   to_date('&start_date 00:00:00', 'mm/dd/yyyy hh24:mi:ss') AND
                   to_date('&end_date 23:59:59', 'mm/dd/yyyy hh24:mi:ss')
AND	    op.order_id = o.order_id
AND 	asa.activity_source_id = o.activity_source_id
AND     op.payment_settled_status_code = 'S'
AND     op.payment_amount > 0
AND     op.company_id = 4000
AND     op.customer_id = cust.customer_id(+)
AND	op.payment_settled_date > to_date('10/20/2002 00:00:00', 'mm/dd/yyyy hh24:mi:ss')
AND     op.payment_method_id = pmi.payment_method_id
-- the next clause excludes PAYADJ types that should go through the adjustment interface.
AND     (op.adjustment_reason_id != 3123597
         or   op.adjustment_reason_id IS NULL
         or   (op.adjustment_reason_id = 3123597 
               and op.payment_amount > 0
               and op.payment_settled_date > to_date('05/31/2003','mm/dd/yyyy')))
AND     pmi.payment_method_id IN
        (SELECT payment_method_id
         FROM   TMP_COE_PAYMENT_METHODS_A
         WHERE  company_id = 4000
         AND    inactive_flag = 0
         AND    adjustment_flag = 0
        )
AND     pmi.payment_method_id NOT IN 
        (2123682, 2123687, 2123684, 2123686, 2123685, 1026)
 -- above clause excludes UNDER, BPO, HCPO, PIN, and VPO, CASH types, respectively
AND EXISTS (SELECT 1 FROM RA_CUSTOMER_TRX_ALL RCT
           WHERE RCT.ATTRIBUTE_CATEGORY = 'RCOM_INTERFACE' 
           AND RCT.BATCH_SOURCE_ID = 1043       -- RCOM_INTERFACE
           AND RCT.ATTRIBUTE2 = OP.ORDER_NUMBER)
AND NOT EXISTS (SELECT 1 FROM AR_CASH_RECEIPTS_ALL ARC, HZ_CUST_ACCOUNTS HCA
           WHERE ARC.ATTRIBUTE_CATEGORY = 'RCOM_INTERFACE' 
           AND ARC.PAY_FROM_CUSTOMER = HCA.CUST_ACCOUNT_ID
           AND ARC.STATUS IN ('APP', 'UNAPP')
           AND ARC.ATTRIBUTE10 = OP.ORDER_NUMBER
           AND ARC.ATTRIBUTE11 = PMI.BASE_CODE
           AND HCA.ACCOUNT_NUMBER = CUST.CUSTOMER_NUMBER)
GROUP BY asa.display_code, CUST.CUSTOMER_NUMBER, OP.ORDER_NUMBER, pmi.display_code
UNION ALL
SELECT  asa.display_code                                   "RCOM_ACTIVITY_SOURCE_CODE",
        'CREDITS'                                          "APPLICATION_TYPE",
        cust.customer_number                               "CUSTOMER_NUMBER",
        op.order_number                                    "ORDER_NUMBER",
        NVL(op.account_number, NVL(op.check_number,'n/a')) "RECEIPT_NUMBER",
        pmi.display_code                                   "PAYMENT_OR_ADJ_TYPE",
        max(TO_CHAR(op.payment_authorized_date,'mm/dd/yyyy'))   "AUTHORIZED_DATE",
        max(TO_CHAR(op.deposited_date,'mm/dd/yyyy'))            "DEPOSITED_DATE",
        max(TO_CHAR(op.payment_settled_date,'mm/dd/yyyy'))      "SETTLED_DATE",
        max(TO_CHAR(op.denied_date,'mm/dd/yyyy'))               "FAILED_DATE",
        0                                                  "RCOM_PAYMENT_AMOUNT",
        0						   "AR_PAYMENT_AMOUNT",
        0						   "AR_RCOM_DIFFERENCE",
        0                                                  "ADJ_AMOUNT",
        sum(op.payment_amount)                             "CR_AMOUNT",
        0                                                  "FAILED_PAYMENT",
        op.attribute01                                     "INTERFACE_BATCH",
        'n/a'						   "COMMENTS"
FROM    TMP_COE_ORDER_PAYMENTS op, TMP_COE_CUSTOMERS cust, TMP_COE_PAYMENT_METHODS_A pmi,
        TMP_COE_ORDERS o, TMP_COE_ACTIVITY_SOURCES_A asa, TMP_EDS_ADJUSTMENTS_INT eai
WHERE   o.company_id = '4000'
AND     op.payment_settled_date BETWEEN 
                   to_date('&start_date 00:00:00', 'mm/dd/yyyy hh24:mi:ss') AND
                   to_date('&end_date 23:59:59', 'mm/dd/yyyy hh24:mi:ss') 
AND     op.order_id = o.order_id
AND     op.payment_settled_status_code = 'S'
AND     op.payment_amount < 0
AND     op.company_id = 4000
AND     op.customer_id = cust.customer_id
AND	op.payment_settled_date > to_date('10/20/2002 00:00:00', 'mm/dd/yyyy hh24:mi:ss')
AND     op.payment_method_id = pmi.payment_method_id
AND     asa.activity_source_id = o.activity_source_id
AND     pmi.payment_method_id IN
        (SELECT payment_method_id
         FROM   TMP_COE_PAYMENT_METHODS_A
         WHERE  company_id = 4000
         AND    inactive_flag = 0
         AND    adjustment_flag = 1 --MLH 5-21-03  
        )
-- this clause added 5-21-03 by MLH to indicate adjustments that create OAR credit memos 
AND    op.adjustment_reason_id IN
                (select distinct(adjustment_reason_id ) 
                 from TMP_EDS_ADJ_INT_PARAMS
                 where create_credit_memo_flag = 1)
AND NOT (OP.adjustment_reason_id = 2123632 AND OP.posted_status_code = 'XP')
AND     pmi.payment_method_id NOT IN 
        (2123687, 1026, 2123684, 2123686, 2123682, 2123685)
 -- above clause excludes BPO, CASH, HCPO, PIN, and VPO types, respectively
AND     op.order_payment_id = eai.order_payment_id
 -- the following clause excludes SHIP adj types that should not create credit memos
AND	(op.adjustment_Reason_id != 1119	-- SHIP adjustment type
	OR (op.adjustment_Reason_id = 1119 
	    AND o.order_Status_id = 1008	--order must be closed
	    AND EXISTS ( SELECT 1		-- at least one shipped line exists
	    		   FROM TMP_COE_ORDER_LINES ol
	    		  WHERE ol.order_id = o.order_id
	    		    AND ol.order_line_Status_id = 1007) -- shipped status
	    )
	 )
GROUP BY asa.display_code, cust.customer_number, op.order_number, op.account_number, op.check_number,
         pmi.display_code, op.attribute01
HAVING  sum(op.payment_amount) NOT IN 
        (SELECT APSA.AMOUNT_DUE_ORIGINAL
         FROM  AR.HZ_CUST_ACCOUNTS HCA, AR.AR_PAYMENT_SCHEDULES_ALL APSA
             , AR_RECEIVABLE_APPLICATIONS_ALL ARA, RA_CUSTOMER_TRX_ALL RCT
         WHERE  APSA.CLASS = 'CM'
           AND  APSA.PROGRAM_ID = 42024 -- program 'FCAR_RCOM_ADJ'
           AND  HCA.CUST_ACCOUNT_ID = APSA.CUSTOMER_ID
           AND  HCA.ACCOUNT_NUMBER = cust.customer_number
           AND  APSA.CUSTOMER_TRX_ID = ARA.CUSTOMER_TRX_ID
           AND  ARA.APPLICATION_TYPE = 'CM'
           AND  ARA.PROGRAM_ID = 42024 -- program 'FCAR_RCOM_ADJ'
           AND  ARA.APPLIED_CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
           AND  RCT.INTERFACE_HEADER_ATTRIBUTE2 = op.order_number)
UNION ALL
SELECT  asa.display_code                                   "RCOM_ACTIVITY_SOURCE_CODE",
        'ADJUSTMENTS'                                      "APPLICATION_TYPE",
        cust.customer_number                               "CUSTOMER_NUMBER",
        op.order_number                                    "ORDER_NUMBER",
        NVL(op.account_number, NVL(op.check_number,'n/a')) "RECEIPT_NUMBER",
        pmi.display_code                                   "PAYMENT_OR_ADJ_TYPE",
        TO_CHAR(op.payment_authorized_date,'mm/dd/yyyy')   "AUTHORIZED_DATE",
        TO_CHAR(op.deposited_date,'mm/dd/yyyy')            "DEPOSITED_DATE",
        TO_CHAR(op.payment_settled_date,'mm/dd/yyyy')      "SETTLED_DATE",
        TO_CHAR(op.denied_date,'mm/dd/yyyy')               "FAILED_DATE",
        0                                                  "RCOM_PAYMENT_AMOUNT",
        0						   "AR_PAYMENT_AMOUNT",
        0						   "AR_RCOM_DIFFERENCE",
        op.payment_amount                                  "ADJ_AMOUNT",
        0                                                  "CR_AMOUNT",
        0                                                  "FAILED_PAYMENT",
        op.attribute01                                     "INTERFACE_BATCH",
        'n/a'						   "COMMENTS"
FROM    TMP_COE_ORDER_PAYMENTS op, TMP_COE_CUSTOMERS cust, TMP_COE_PAYMENT_METHODS_A pmi,
        TMP_COE_ORDERS o, TMP_COE_ACTIVITY_SOURCES_A asa
WHERE   o.company_id = '4000'
AND     op.payment_settled_date BETWEEN 
                   to_date('&start_date 00:00:00', 'mm/dd/yyyy hh24:mi:ss') AND
                   to_date('&end_date 23:59:59', 'mm/dd/yyyy hh24:mi:ss')
AND     op.order_id = o.order_id
AND     op.order_number IS NOT NULL
AND     op.payment_settled_status_code = 'S'
AND     op.payment_posted_status_code in ('R', 'N', 'C') 
AND     op.company_id = 4000
AND	op.payment_settled_date > to_date('10/20/2002 00:00:00', 'mm/dd/yyyy hh24:mi:ss')
AND     op.customer_id = cust.customer_id
AND 	cust.customer_number != '1005'
AND NOT (full_name LIKE 'FRANKLIN COVEY #7%'
         AND LENGTH (customer_number) = 3)
AND     op.adjustment_flag = 0
AND     op.attribute01 IS NULL
AND     op.payment_method_id = pmi.payment_method_id
AND     pmi.credit_card_flag = 1
AND     asa.activity_source_id = o.activity_source_id
AND     asa.base_code NOT IN
                    ('IUSE', 'RTLNET', 'CHGOVT', 'ASSIST', 'CNV')
-- the following clause was added in conjunction with changing adjustment_flag = 0 to get PAYADJ records.
--  All other adjustment types are picked up in the CREDITS section above. 
--AND     op.adjustment_reason_id = 3123597
-- CHANGED 5/29
AND	op.payment_amount < 0
-- this checks to see if adjustments to the order have been processed to balance the payment
AND 	op.payment_amount < nvl((select sum(op2.payment_amount)
				   	  from TMP_coe_order_payments op2
					  where op2.order_number = op.order_number
					  and op2.adjustment_flag = 1
					  and op2.payment_amount < 0
					  and op2.attribute01 is not null),0)
AND NOT EXISTS
        (
        SELECT 1 
        FROM   AR.RA_CUSTOMER_TRX_ALL RCTA, AR.AR_ADJUSTMENTS_ALL  AAA
        WHERE  rcta.interface_header_attribute1 = cust.customer_number
        AND    rcta.interface_header_attribute2 = op.order_number
        AND    rcta.batch_source_id = 1043 -- RCOM_INTERFACE
        AND    aaa.receivables_trx_id = 1060  -- FC NEGATIVE PAYMENT ADJUSTMENT--to pick ADJ created by MANUAL and INTERFACE
        AND    rcta.customer_trx_id = aaa.customer_trx_id
        AND    aaa.status = 'A'
        AND    aaa.amount = op.payment_amount  -- ADJ AMOUNT
        AND    ROWNUM < 2
        )
ORDER BY 7, 1, 2, 4 DESC;

