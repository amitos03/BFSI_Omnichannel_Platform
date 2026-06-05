with customers as (
    select * from {{ ref('stg_core_customers') }}
),

telemetry as (
    select * from {{ ref('stg_mobile_telemetry') }}
),

-- Aggregate the mobile app clickstream data per customer
telemetry_aggregated as (
    select
        customer_id,
        count(distinct event_id) as total_app_events,
        max(event_timestamp) as last_active_app_timestamp,
        sum(session_duration_seconds) as total_app_time_seconds
    from telemetry
    where customer_id is not null
    group by customer_id
)

-- Join the core banking profile with the aggregated telemetry
select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.ssn,
    c.email,
    c.account_balance,
    c.is_kyc_verified,
    coalesce(ta.total_app_events, 0) as total_app_events,
    ta.last_active_app_timestamp,
    coalesce(ta.total_app_time_seconds, 0) as total_app_time_seconds
from customers c
left join telemetry_aggregated ta
    on c.customer_id = ta.customer_id