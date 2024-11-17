-- calculate total chargeback count by country

select 
    transaction_country
    ,sum(case when is_chargeback then 1 else 0 end) as total_chargebacks
from datamodelingchallenge.transactions
group by 1 