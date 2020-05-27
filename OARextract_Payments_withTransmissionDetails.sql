-- SQL to extract Payment Details in Oracle AR
-- Enter begin and end dates with single quotes e.g. '10/17/2002' and '05/31/2003'
select arc.receipt_number
   , arc.receipt_date
   , arc.deposit_date
   , arc.type cash_receipt_type
   , arc.attribute11 cash_receipt_payment_type
   , arc.amount cash_receipt_amount
   , arc.currency_code
   , arc.confirmed_flag
   , arc.cash_receipt_id
   , ara.cash_receipt_history_id
   , arch.acctd_amount functional_amount
   , arch.amount amount_in_trans_currency
   , rct.trx_number invoice_number
   , rct.trx_date invoice_date
   , rbs.name batch_source_name
   , rct.orig_system_batch_name
   , rct.attribute_category batch_source
   , rct.interface_header_context batch_source_context
   , hca.account_number customer_number
   , rct.interface_header_attribute2 order_number
   , rct.purchase_order
   , rct.comments
   , rctt.name transaction_type_name
   , rctt.type transction_type
   , arm.receipt_method_id
   , arm.name receipt_method_name
   , ara.code_combination_id
   , ara.applied_customer_trx_id
   , ara.applied_customer_trx_line_id
   , ara.customer_trx_id
   , ara.gl_posted_date
   , ara.posting_control_id
   , ara.confirmed_flag
   , arc.status cash_receipt_status
   , arch.status cash_rec_hist_status
   , ara.status rec_appl_status
   , SUM(ara.amount_applied) rec_appl_amount_entered
   , SUM(nvl(ara.acctd_amount_applied_to, ara.amount_applied) * nvl(aps.exchange_rate,1)) rec_appl_amount_functional
   , ARBA.NAME RCPT_BATCH_NAME
   , ARTL.TRANSMISSION_NAME RCPT_TRANSMISSION_NAME
from ra_customer_trx_all rct
   , ar_cash_receipts_all arc
   , ar_cash_receipt_history_all arch
   , ar_receivable_applications_all ara
   , ra_cust_trx_types_all rctt
   , ra_batch_sources_all rbs
   , ar_receipt_methods arm
   , ar_lookups al
   , hz_cust_accounts HCA
   , ar_payment_schedules_all aps
   , AR_BATCHES_ALL ARBA
   , AR_TRANSMISSIONS_ALL ARTL
where arc.cash_receipt_id = ara.cash_receipt_id
   and arc.cash_receipt_id = arch.cash_receipt_id
   and arch.cash_receipt_history_id = ara.cash_receipt_history_id
   and aps.cash_receipt_id = arc.cash_receipt_id
   and aps.payment_schedule_id = ara.payment_schedule_id
   and ara.applied_customer_trx_id = rct.customer_trx_id (+)
   and rct.cust_trx_type_id = rctt.cust_trx_type_id (+)
   and rct.batch_source_id = rbs.batch_source_id (+)
   and arc.pay_from_customer = hca.cust_account_id (+) 
   and arm.receipt_method_id = arc.receipt_method_id
   and al.lookup_code = arc.status
   and al.lookup_type = 'CHECK_STATUS'
   and rctt.org_id (+) = 101
   and rbs.org_id (+) = 101
   and arc.deposit_date between to_date(&begin_date, 'MM/DD/YYYY') and to_date(&end_date, 'MM/DD/YYYY')
   AND ARBA.BATCH_ID = ARCH.BATCH_ID
   AND ARTL.TRANSMISSION_ID = ARBA.TRANSMISSION_ID
GROUP BY arc.receipt_number
   , arc.receipt_date
   , arc.deposit_date
   , arc.type
   , arc.attribute11
   , arc.amount
   , arc.currency_code
   , arc.confirmed_flag
   , arc.cash_receipt_id
   , ara.cash_receipt_history_id
   , arch.acctd_amount
   , arch.amount
   , rct.trx_number
   , rct.trx_date
   , rbs.name
   , rct.orig_system_batch_name
   , rct.attribute_category
   , rct.interface_header_context
   , hca.account_number
   , rct.interface_header_attribute2
   , rct.purchase_order
   , rct.comments
   , rctt.name
   , rctt.type
   , arm.receipt_method_id
   , arm.name
   , ara.code_combination_id
   , ara.applied_customer_trx_id
   , ara.applied_customer_trx_line_id
   , ara.customer_trx_id
   , ara.gl_posted_date
   , ara.posting_control_id
   , ara.confirmed_flag
   , arc.status
   , arch.status
   , ara.status
   , ARBA.NAME
   , ARTL.TRANSMISSION_NAME
HAVING sum(ara.AMOUNT_APPLIED) != 0
