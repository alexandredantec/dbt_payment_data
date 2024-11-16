{{ config(materialized='table') }}

with transactions as (

    select 
    ref as transaction_id
    ,external_ref as chargeback_id

    ,country as transaction_country
    ,currency as transaction_currency
    ,rates as exchange_rates

    ,status as transaction_status
    ,source as transaction_source
    ,state as transaction_state

    ,amount as transaction_amount
    ,cvv_provided as is_cvv_provided
    ,date_time as transaction_date

    from {{ source('globepay', 'acceptance_report') }}

)

select *
from transactions