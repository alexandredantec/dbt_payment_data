{% docs stg_transactions__transactions %}
Transactions from the Globepay API - a transaction represents a debit or credit card payment processed for Deel through the Globepay API 
{% enddocs %}

{% docs stg_transactions__transaction_id %}
Unique identifier of the transaction event
{% enddocs %}

{% docs stg_transactions__transaction_country %}
Country in which the transaction originated (i.e. Country where the card was issued)
{% enddocs %}

{% docs stg_transactions__transaction_currency %}
Currency in which the transaction was issued 
{% enddocs %}

{% docs stg_transactions__exchange_rates %}
Exchange rates for all available currencies at the point the transaction was processed 
{% enddocs %}

{% docs stg_transactions__transaction_source %}
The payment service provider through which the transaction was processed (e.g. Globepay)
{% enddocs %}

{% docs stg_transactions__transaction_state %}
State of the transaction, i.e. whether it was accepted or declined 
{% enddocs %}

{% docs stg_transactions__transaction_amount %}
Amount of the transaction in local currency 
{% enddocs %}

{% docs stg_transactions__is_cvv_provided %}
Indicates whether the card security code (CVV) was provided during payment, expressed as a Boolean
{% enddocs %}

{% docs stg_transactions__transaction_date %}
Timestamp at which the transaction was processed, i.e. the timestamp for the API response  
{% enddocs %}