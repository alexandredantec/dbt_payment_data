
with

transactions as (

        select * from {{ref('int_transactions')}}

),

final as (
    
    select

        transactions.transaction_id
        ,transactions.chargeback_id

        ,transactions.transaction_country
        ,transactions.transaction_currency
        ,transactions.exchange_rate

        ,transactions.transaction_source
        ,transactions.transaction_state

        ,transactions.original_currency_amount
        ,transactions.usd_amount

        ,transactions.is_cvv_provided
        ,transactions.is_chargeback

        ,transactions.transaction_date
        ,transactions.transaction_month
        ,transactions.transaction_week

    from transactions

)

select * from final