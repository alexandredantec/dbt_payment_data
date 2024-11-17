The aim of this dbt project is to transform transaction and chargeback data from the Globepay API

### Globepay API (source: assignment brief):
Deel clients can add funds to their Deel account using their credit and debit cards. Deel has
partnered with Globepay to process all of these account funding credit and debit card
transactions. Globepay is an industry-leading global payment processor and is able to process
payments in many currencies from cards domiciled in many countries.

Deel has connectivity into Globepay using their API. Deel clients provide their credit and
debit details within the Deel web application, Deel systems pass those credentials along with
any relevant transaction details to Globepay for processing.


### Available Tables:

- `acceptance_report`: transaction data from the Globepay API - a transaction represents a debit or credit card payment processed for Deel through the Globepay API 
- `chargeback_report`: chargeback data from the Globepay API - a chargeback is a charge that is returned to a payment method following a succesful dispute

### Preliminary Data Exploration:
- check unicity between the two models:
```
select count(*) --5430
from `globepay.acceptance_report`
union all
select count(*) --5430 
from `globepay.chargeback_report`
```

- check that all records exist in both models, and that `external_ref` is the correct join key:
```
select count(*) --0
from `globepay.acceptance_report`
where external_ref not in (select external_ref from `globepay.chargeback_report`)

select count(*) --0
from `globepay.chargeback_report`
where external_ref not in (select external_ref from `globepay.acceptance_report`)
```

- check possible `state` column values in `acceptance_report`:
```
select distinct state from `globepay.acceptance_report`
```
--> outputs `ACCEPTED` and `DECLINED`

- check possible `currency`/`country` values in `acceptance_report`:
```
select distinct currency,country from `globepay.acceptance_report`
```

--> there are no countries where multiple currencies are used, and two countries seem to process transactions in USD, the US and the United Arab Emirates (ISO country code: AE) 

Other similar checks were carried out to identify discrepancies in status, data type, or source. The only difficult point is the fact that exchange rates are stored as a json column and need to be extracted   

### Architecture Overview:

#### Data Extraction 
- both models are imported to BigQuery as csv files 
- BigQuery was chosen as it is very easy to connect to dbt core and exploit locally 
- The main tradeoff of using BigQuery rather than Snowflake is the lack of dynamic column aliasing

#### Data Modeling 
- both raw tables were recreated as staging models in dbt 
- these two staging models were joined in an intermediate model called `int_transactions`
- the reason this was done is because there is a complete 1-1 relationship between transactions and chargebacks: the only added information in the chargeback model is a Boolean indicating whether a transaction incurred a chargeback. There is no date column or anything suggesting there is a loose relationship between transaction and chargeback 
- this allows for optimal analytical processing, as the `int_transactions` model can be used as a fact model which could be joined on other dimensions as part of a star/snowflake schema if we had other tables   
- a jinja function was used to dynamically extract the currency from the `exchange_rates` (initially named `rates`) column
- this generates multiple columns, which are then unpivoted to generate a single `exchange_rate` column, which is then used to calculate the USD amount of any non USD transaction
