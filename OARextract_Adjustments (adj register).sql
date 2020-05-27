-- SQL to extract ADJUSTMENTS in Oracle AR
-- Enter begin and end dates with single quotes e.g. '10/17/2002' and '05/31/2003'
-- Added joins to AR_DISTRIBUTIONS_ALL, GL_CODE_COMBINATIONS, and
-- AR_PAYMENT_SCHEDULES_ALL tables to match Adjustment Register code
SELECT SUBSTR(F.NAME,1,15) SOURCE, D.NAME TRANSACTION_TYPE, A.TRX_NUMBER INVOICE_NUMBER
   , A.TRX_DATE INVOICE_DATE, G.ACCOUNT_NUMBER CUSTOMER_NUMBER
   , A.INTERFACE_HEADER_ATTRIBUTE2 ORDER_NUMBER
   , B.ADJUSTMENT_NUMBER, C.NAME ADJ_TYPE, E.MEANING ADJ_STATUS, A.INVOICE_CURRENCY_CODE CURRENCY_CODE
   , B.AMOUNT ADJ_AMOUNT_ENTERED, B.ACCTD_AMOUNT ADJ_AMOUNT_FUNCTIONAL
   , TRUNC(B.APPLY_DATE) APPLY_DATE, TRUNC(B.GL_DATE) GL_DATE
   , DECODE(B.CREATED_FROM, 'ADJ-API','Adjustments_Interface_Program-FCAR_RCOM_ADJ'
   , 'ARXAAP', 'Auto_Adjustments_Program-ARXAAP', 'ARXTWADJ', 'ADJUSTMENTS_MANUAL'
   , 'FCAR_DEC_ADJ_CONV', 'Dec_Conversion-FCAR_DEC_ADJ_CONV'
   , 'FCAR_DEC_ADJ_ROUNDING', 'Dec_Conversion-FCAR_DEC_ADJ_ROUNDING', B.CREATED_FROM) ADJ_CREATED_FROM
   , A.EXCHANGE_RATE, A.EXCHANGE_DATE, A.EXCHANGE_RATE_TYPE
FROM RA_CUSTOMER_TRX_ALL A, AR_ADJUSTMENTS_ALL B, AR_RECEIVABLES_TRX_ALL C
   , RA_CUST_TRX_TYPES_ALL D, AR_LOOKUPS E, RA_BATCH_SOURCES_ALL F, HZ_CUST_ACCOUNTS G
   , AR_DISTRIBUTIONS_ALL DIST, GL_CODE_COMBINATIONS GL, AR_PAYMENT_SCHEDULES_ALL PAY
WHERE B.CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
AND B.RECEIVABLES_TRX_ID = C.RECEIVABLES_TRX_ID
AND C.ORG_ID = 101
AND D.CUST_TRX_TYPE_ID = A.CUST_TRX_TYPE_ID
AND E.LOOKUP_TYPE = 'APPROVAL_TYPE'
AND E.LOOKUP_CODE = B.STATUS
AND F.BATCH_SOURCE_ID = A.BATCH_SOURCE_ID
AND F.ORG_ID = 101
AND G.CUST_ACCOUNT_ID = A.BILL_TO_CUSTOMER_ID
AND A.TRX_DATE BETWEEN TO_DATE(&begin_date, 'MM/DD/YYYY') AND TO_DATE(&end_date, 'MM/DD/YYYY')
AND DIST.CODE_COMBINATION_ID = GL.CODE_COMBINATION_ID
AND DIST.SOURCE_ID = B.ADJUSTMENT_ID
AND DIST.SOURCE_TYPE = 'ADJ'
AND A.COMPLETE_FLAG = 'Y'
AND A.CUSTOMER_TRX_ID = PAY.CUSTOMER_TRX_ID
AND PAY.PAYMENT_SCHEDULE_ID = B.PAYMENT_SCHEDULE_ID
ORDER BY SUBSTR(F.NAME,1,15), D.NAME, C.NAME, A.TRX_DATE;