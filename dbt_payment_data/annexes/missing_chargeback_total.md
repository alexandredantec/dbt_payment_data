-- calculate total number of missing chargebacks

select 
    count(transaction_id) as missing_chargeback_total
from datamodelingchallenge.transactions
where is_chargeback is null