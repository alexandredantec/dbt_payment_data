-- calculate acceptance_rate by country

with base as (
    select
      transaction_month
      ,transaction_country
      ,count(*) as total
      ,sum(case when transaction_state = 'ACCEPTED' then 1 else 0 end) as total_accepted
    from datamodelingchallenge.transactions
    group by 1,2 
  )

  select
    transaction_month
    ,transaction_country
    ,round(total_accepted/total, 3) as acceptance_rate 
  from base 
  order by 1 