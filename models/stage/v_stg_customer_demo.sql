{%- set yaml_metadata -%}
source_model: 'raw_customers'
derived_columns:
  RECORD_SOURCE: '!TPCH-ORDERS'
  EFFECTIVE_FROM: 'ORDERDATE'
  EFFECTIVE_TO: "NVL(LAG(ORDERDATE) OVER (PARTITION BY CUSTOMERKEY ORDER BY ORDERDATE DESC),TO_DATE('12/31/9999'))"

limit_col: 'LOAD_DATE'
hashed_columns:
  CUSTOMER_PK: 
    - 'CUSTOMERKEY'
  CUSTOMER_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CUSTOMER_NAME'
      - 'CUSTOMER_ADDRESS'
      - 'CUSTOMER_PHONE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{% set source_model = metadata_dict['source_model'] %}

{% set derived_columns = metadata_dict['derived_columns'] %}

{% set hashed_columns = metadata_dict['hashed_columns'] %}

{% set ranked_columns = metadata_dict['ranked_columns'] %}

{% set limit_col = metadata_dict['limit_col'] %}

WITH staging AS (
{{ dbtvault.stage(include_source_columns=none,
                  source_model=source_model,
                  derived_columns=derived_columns,
                  hashed_columns=hashed_columns,
                  ranked_columns=none) }}
)

SELECT *,
       TO_DATE(CURRENT_TIMESTAMP()) AS LOAD_DTM
FROM staging