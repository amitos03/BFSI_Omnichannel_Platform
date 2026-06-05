with raw_source as (
    select * from {{ source('bronze_layer', 'raw_customers_batch') }}
),

renamed_and_cast as (
    select
        raw_payload:customer_id::string as customer_id,
        trim(raw_payload:first_name::string) as first_name,
        trim(raw_payload:last_name::string) as last_name,
        trim(raw_payload:ssn::string) as ssn,
        trim(raw_payload:email::string) as email,
        raw_payload:account_balance::float as account_balance,
        raw_payload:kyc_verified::boolean as is_kyc_verified,
        ingested_at as loaded_at
    from raw_source
)

select * from renamed_and_cast