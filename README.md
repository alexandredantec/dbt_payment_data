The aim of this dbt project is to transform transaction and chargeback data from the Globepay API

### Globepay API (source: assignment brief, company name changed):
AwesomeCompany clients can add funds to their AwesomeCompany account using their credit and debit cards. AwesomeCompany has
partnered with Globepay to process all of these account funding credit and debit card
transactions. Globepay is an industry-leading global payment processor and is able to process
payments in many currencies from cards domiciled in many countries.

AwesomeCompany has connectivity into Globepay using their API. AwesomeCompany clients provide their credit and
debit details within the AwesomeCompany web application, AwesomeCompany systems pass those credentials along with
any relevant transaction details to Globepay for processing.


### Available Tables:

- `acceptance_report`: transaction data from the Globepay API - a transaction represents a debit or credit card payment processed for AwesomeCompany through the Globepay API 
- `chargeback_report`: chargeback data from the Globepay API - a chargeback is a charge that is returned to a payment method following a succesful dispute

### Preliminary Data Exploration:
- Check unicity between the two models:
```
select count(*) --5430
from `globepay.acceptance_report`
union all
select count(*) --5430 
from `globepay.chargeback_report`
```

- Check that all records exist in both models, and that `external_ref` is the correct join key:
```
select count(*) --0
from `globepay.acceptance_report`
where external_ref not in (select external_ref from `globepay.chargeback_report`)

select count(*) --0
from `globepay.chargeback_report`
where external_ref not in (select external_ref from `globepay.acceptance_report`)
```

- Check possible `state` column values in `acceptance_report`:
```
select distinct state from `globepay.acceptance_report`
```
--> Outputs `ACCEPTED` and `DECLINED`

- Check possible `currency`/`country` values in `acceptance_report`:
```
select distinct currency,country from `globepay.acceptance_report`
```

--> There are no countries where multiple currencies are used, and two countries seem to process transactions in USD, the US and the United Arab Emirates (ISO country code: AE) 

Other similar checks were carried out to identify discrepancies in status, data type, or source. The only difficult point is the fact that exchange rates are stored as a json column and need to be extracted

Two other consistency tests were carried out during the analysis phase: 

- A comparison of the exchange rates with their real world counterparts to ensure they all work in the same way and contain the value of 1 USD in the local currency 
- A basic overview of the dates using `max()` and `min()` to ensure there are no outliers 

More tests are available in the PR history on the git repo 

### Architecture Overview:

#### Data Extraction 
- Both models are imported to BigQuery as csv files 
- BigQuery was chosen as it is very easy to connect to dbt core and exploit locally 
- The main tradeoff of using BigQuery rather than Snowflake is the lack of dynamic column aliasing
- Since the data is contained in static csv, no thought was given to partitioning or incrementalization. This would be done in a production context 

#### Data Modeling 
- Both raw tables were recreated as staging models in dbt 
- These two staging models were joined in an intermediate model called `int_transactions`
- The reason this was done is because there is a complete 1-1 relationship between transactions and chargebacks: the only added information in the chargeback model is a Boolean indicating whether a transaction incurred a chargeback. There is no date column or anything suggesting there is a loose relationship between transaction and chargeback 
- An analytical model called `fct_transactions` was added to expose to data consumers and BI tools 
- This allows for optimal analytical processing, as the `fct_transactions` model can be used as a fact model which could be joined on other dimensions as part of a star/snowflake schema if we had other tables   

#### Code Modularity 
- A Jinja function was used to dynamically extract the currency from the `exchange_rates` (initially named `rates`) column
- This generates multiple columns, which are then unpivoted to generate a single `exchange_rate` column, which is then used to calculate the USD amount of any non USD transaction
- Since these jinja functions are only called once, they remain part of the `int_transactions` model. A further improvement Would be to turn the jinja code into macros to extract currency and calculate USD amount 

#### Materialization
- All the models were materialized as tables
- This is due to the small scale of the project, and the need to access `stg_transactions` using the `dbt_utils.get_column_values` function
- In a larger model where staging tables are not supposed to be externally accessible, these could be materialized as views 

### Testing Strategy
- Off the-shelf dbt tests (`not_null`, `unique`) were used to check unique_id consistency 
- A specifically created macro called `not_zero.sql` was leveraged to ensure no currency rate is `0`
- To further prevent division by zero, a condition was added to the `case` statement calculating `usd_amount` to output `null`  
- This was completed by a `not_null` test on `usd_amount` in case the currency rate is `null`
- This could be completed by `accepted_values` tests on `transaction_source` and `chargeback_source` to ensure the data team is aware of any unexpected values, or in case a new PSP is added 
- In a real-world scenario, these would be completed by data freshness tests to ensure data is up to date and consistent 
- In an ideal world, some form of unit testing and volumetry checks would also be implemented 

### Documentation
- Documentation was created using a doc.md file for each layer (`staging`, `intermediate`) to ensure documentation remains DRY
- Column level documentation is defined at the lowest level, i.e. where a field first appears, and then called further downstream 
- The documentation can be retrieved using `dbt docs serve` / `dbt docs generate`
- The purpose of the documentation is to guide any new team member / technically savvy business stakeholder understand the data
- For non technical business stakeholders, documentation should live in a data catalogue or as part of a BI tool (e.g. Looker)

### Lineage Overview:
![image](https://github.com/user-attachments/assets/fce02ef7-d1fa-4ab7-b5fa-213ebea47170)
