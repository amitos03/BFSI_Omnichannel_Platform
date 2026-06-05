with raw_source as (
    select * from {{ source('bronze_layer', 'raw_mobile_telemetry') }}
),

flattened_events as (
    select
        raw_payload:event_id::string as event_id,
        raw_payload:timestamp::timestamp_ntz as event_timestamp,
        raw_payload:app_version::string as app_version,
        
        -- Flattening the nested 'user' node
        raw_payload:payload:user:customer_id::string as customer_id,
        raw_payload:payload:user:device_os::string as device_os,
        raw_payload:payload:user:ip_address::string as ip_address,
        
        -- Flattening the nested 'action' node
        raw_payload:payload:action:screen_name::string as screen_name,
        raw_payload:payload:action:button_clicked::string as button_clicked,
        raw_payload:payload:action:session_duration_seconds::integer as session_duration_seconds,
        
        ingested_at as loaded_at
    from raw_source
)

select * from flattened_events