-- calculate total chargeback value by country

select 
    transaction_country
    ,sum(case when is_chargeback then usd_amount else 0 end) as total_chargebacks
from datamodelingchallenge.transactions
group by 1