-- calculate total chargeback count

select 
    count(transaction_id) as total_chargebacks
from datamodelingchallenge.transactions
where is_chargeback is true