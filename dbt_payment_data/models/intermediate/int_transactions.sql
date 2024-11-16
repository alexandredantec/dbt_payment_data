{% set currencies = dbt_utils.get_column_values(table=ref('stg_transactions'), column='transaction_currency') %}

with

transactions as (

        select * from {{ref('stg_transactions')}}

),

extract_rates as (

    select

        transaction_id
        ,chargeback_id

        ,transaction_country
        ,transaction_currency
        ,exchange_rates

        ,transaction_status
        ,transaction_source
        ,transaction_state

        ,transaction_amount
        ,is_cvv_provided
        ,transaction_date
        {% for currency in currencies %}
        ,case 
            when transaction_currency = '{{currency}}' then cast(json_extract(exchange_rates, '$.{{currency}}')as float64)
            else null
        end as {{currency}}_rate
        {% endfor %}
                
    from transactions
),

final as (
    
    select

        transaction_id
        ,chargeback_id

        ,transaction_country
        ,transaction_currency
        ,exchange_rate

        ,transaction_status
        ,transaction_source
        ,transaction_state

        ,transaction_amount as original_currency_amount
        ,case
            when transaction_currency = 'USD' then transaction_amount
            else transaction_amount / exchange_rate
        end as usd_amount
        ,is_cvv_provided
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

