{{ config(materialized='table') }}

with chargebacks as (

    select 
    external_ref as chargeback_id
    ,status as chargeback_status
    ,source as chargeback_source
    ,chargeback as is_chargeback

    from {{ source('globepay', 'chargeback_report') }}

)

select *
from chargebacks