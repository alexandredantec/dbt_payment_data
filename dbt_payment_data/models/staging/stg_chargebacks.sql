
with chargebacks as (

    select 
    external_ref as chargeback_id
    ,source as chargeback_source
    ,chargeback as is_chargeback
    ,status as is_successful_request

    from {{ source('globepay', 'chargeback_report') }}

)

select *
from chargebacks