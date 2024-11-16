{{ config(materialized='table') }}

with chargebacks as (

    select 
    external_ref as chargeback_id
    ,status as chargeback_status
    ,source as chargeback_source
    ,chargeback as is_chargeback

    from {{ source('global_pay', 'chargeback_report') }}

)

select *
from chargebacks