{% set currencies = dbt_utils.get_column_values(table=ref('stg_transactions'), column='transaction_currency') %}

with

transactions as (

        select * from {{ref('stg_transactions')}}

),

chargebacks as (

        select * from {{ref('stg_chargebacks')}}

),

extract_rates as (

    select

        transactions.transaction_id
        ,transactions.chargeback_id

        ,transactions.transaction_country
        ,transactions.transaction_currency
        ,transactions.exchange_rates

        ,transactions.transaction_source
        ,transactions.transaction_state

        ,transactions.transaction_amount

        ,transactions.is_cvv_provided
        ,transactions.is_successful_request
        ,chargebacks.is_chargeback

        ,transactions.transaction_date
        {% for currency in currencies %}
        ,case 
            when transactions.transaction_currency = '{{currency}}' then coalesce(safe_cast(json_extract(transactions.exchange_rates, '$.{{currency}}')as float64),0)
            else null
        end as {{currency}}_rate
        {% endfor %}
                
    from transactions
    left join chargebacks
        on transactions.chargeback_id = chargebacks.chargeback_id
),

final as (
    
    select

        transaction_id
        ,chargeback_id

        ,transaction_country
        ,transaction_currency
        ,exchange_rate

        ,transaction_source
        ,transaction_state

        ,transaction_amount as original_currency_amount
        ,case
            when transaction_currency = 'USD' then transaction_amount
            when exchange_rate is null or exchange_rate = 0 then null
            else transaction_amount / exchange_rate
        end as usd_amount

        ,is_cvv_provided
        ,is_successful_request
        ,is_chargeback

        ,transaction_date

    from extract_rates

    unpivot (

        exchange_rate for rate in (

            {% for currency in currencies %}
                {{currency}}_rate
                {% if not loop.last %}
                ,
                {% endif %}
            {% endfor %}

        )
    )

)

select * from final

