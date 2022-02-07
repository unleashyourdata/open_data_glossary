SELECT
    --needed by purchase_delivery_status_value 
    inbound_purchase_override_status,
    is_purchase_auto_release,
    ownership_model,

    --core fields
    inventory_id,
    vrm,
    inspection_make                     AS make,
    inspection_model                    AS model,
    planned_prep_centre                 AS purchase_deliver_to,
    purchase_date, 
    purchase_source, 
    purchase_source                     AS purchase_delivered_by,
    purchase_location,
    --purchase_delivery_status_value    AS purchase_delivery_status,
    netsuite_first_payment_date,
    inbound_purchase_transit_provider,
    inbound_purchase_request_date       AS inbound_purchase_transit_request_date,
    inbound_purchase_request_date       AS inbound_purchase_days_since_transit_request_date,
    inbound_purchase_notes,
    inbound_purchase_updated_by,
    consolidated_state,
    netsuite_total_amount               AS netsuite_total_payment_amount,
    first_seen_in_prep_centre_at        AS first_seen_in_prep_centre_date,
    vin,
    colour,
    fuel_type,
    transmission_type,
    derivative,
    inbound_purchase_sfs_production_complete_date
FROM
    looker_consolidation.inventory





--derivative 

Trim left 100 characters

--inbound_purchase_days_since_transit_request_date

DATEDIFF(inbound_purchase_request_date, DATE(NOW())

--inbound_purchase_transit_request_date

Replace NULL with now()
Format date as '%Y-%m-%d'

--inbound_purchase_transit_provider

Replace NULL with ''

--purchase_delivery_status

** inbound_purchase_override_status
?? purchase_arrived
*consolidated_state
*purchase_source
?? purchase_paid
** is_purchase_auto_release
?? requires_delivery_confirmation_by_vendor
** ownership_model
?? is_sfs_production
*inbound_purchase_sfs_production_complete_date
?? purchase_transit_requested
*purchase_delivered_by


IFNULL(${inbound_purchase_override_status}, IF(
        ${purchase_arrived},
        'Delivered',
        IF(
          ${consolidated_state} IN ('Disposed', 'Sold', 'Sold to Wholesale', 'Fleet', 'Purchase Cancelled'),
          'N/A',
          IF(
            ${purchase_source} IN ('Cazoo P/X', 'Cazoo SC'),
            IF(
              ${location} IS NOT NULL,
              'Awaiting Internal Transport',
              'Awaiting Handover from Customer'
            ),
            IF(
              ${purchase_paid}
                OR ${is_purchase_auto_release}
                OR ${requires_delivery_confirmation_by_vendor}
                OR ${ownership_model} = 'acquisition-on-consignment',
              IF(
                ${is_sfs_production},
                IF(
                  ${inbound_purchase_sfs_production_complete_date} IS NULL,
                  'Awaiting SFS Production',
                  'SFS Production Complete'
                ),
                IF (
                  ${purchase_transit_requested},
                  'Awaiting Delivery',
                  IF(
                    ${requires_delivery_confirmation_by_vendor},
                    'Awaiting Release by Vendor',
                    IF(
                      ${purchase_delivered_by} = 'Vendor',
                      'Vendor Organising Delivery',
                      IF(
                        ${purchase_delivered_by} = 'Cazoo',
                        IF(
                          ${purchase_source} IN ('The AA', 'Onto', 'Motability', 'Arval'),
                          'Awaiting Release Note',
                          'Request Transport'
                        ),
                        'Error - unknown transit provider'
                      )
                    )
                  )

--purchase_delivered_by

"CASE ${purchase_source}
      WHEN 'The AA' THEN 'Cazoo'
      WHEN 'Adesa' THEN 'Cazoo'
      WHEN 'ALD' THEN 'Cazoo'
      WHEN 'ALD (On Consignment)' THEN 'Vendor'
      WHEN 'Arval' THEN 'Cazoo'
      WHEN 'AB' THEN 'Cazoo'
      WHEN 'Autorola' THEN 'Vendor'
      WHEN 'Avis/Budget' THEN 'Vendor'
      WHEN 'BCA' THEN IF(${purchase_date} < '2021-08-11', 'Vendor', 'Cazoo')
      WHEN 'Carfleet' THEN 'Cazoo'
      WHEN 'City Auction' THEN 'Cazoo'
      WHEN 'CLM' THEN 'Cazoo'
      WHEN 'Daimler' THEN 'Cazoo'
      WHEN 'Enterprise' THEN 'Cazoo'
      WHEN 'Europcar' THEN 'Cazoo'
      WHEN 'Europcar' THEN 'Cazoo'
      WHEN 'G3' THEN 'Cazoo'
      WHEN 'G3' THEN 'Cazoo'
      WHEN 'Global' THEN 'Cazoo'
      WHEN 'Leaseplan' THEN 'Cazoo'
      WHEN 'Manheim' THEN 'Vendor'
      WHEN 'Meridian' THEN 'Cazoo'
      WHEN 'Motability' THEN 'Cazoo'
      WHEN 'M4YM' THEN 'Vendor'
      WHEN 'NVCRetail' THEN 'Vendor'
      WHEN 'Private' THEN 'Cazoo'
      WHEN 'RCI Bulk' THEN 'Cazoo'
      WHEN 'Robins and Day' THEN 'Cazoo'
      WHEN 'RWH' THEN 'Cazoo'
      WHEN 'Thrifty' THEN 'Vendor'
      WHEN 'VWFS' THEN 'Cazoo'
      WHEN 'Jordans' THEN 'Vendor'
      WHEN 'BCA-Lex' THEN 'Vendor'
      WHEN 'Hertz' THEN 'Cazoo'
      WHEN 'PW' THEN 'Vendor'
      WHEN 'Tusker' THEN 'Vendor'
      WHEN 'Hitachi' THEN 'Vendor'
      WHEN 'MotabilityNonSFS' THEN 'Vendor'
      WHEN 'TCBG' THEN 'Vendor'
      WHEN 'Liquid Fleet' THEN 'Vendor'
      WHEN 'Leasys Clickar' THEN 'Vendor'
      WHEN 'BCA LCV' THEN 'Vendor'
      WHEN 'Aston Barclay LCV' THEN 'Vendor'
      WHEN 'Manheim LCV' THEN 'Vendor'
      WHEN 'Fleet LCV' THEN 'Vendor'
      WHEN 'G3 LCV' THEN 'Vendor'
      ELSE 'Cazoo'"


--purchase_source

IFNULL(CONCAT(${TABLE}.purchase_source, IF(${ownership_model} = 'acquisition-on-consignment', ' (On Consignment)', '')), '') ;;











    CREATE TABLE `looker_consolidation`.`inventory` (
  `inventory_id` varchar(50) DEFAULT NULL,
  `vrm` varchar(10) NULL DEFAULT NULL,
  `next_inventory_id_for_vrm` varchar(50) DEFAULT NULL,
  `vin` varchar(20) DEFAULT NULL,
  `consolidated_state` varchar(255) DEFAULT NULL,
  `consolidated_state_updated_at` timestamp DEFAULT NULL,
  `registration_date` date DEFAULT NULL,
  `mileage` int(10) DEFAULT NULL,
  `make` varchar(255) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `trim` varchar(255) DEFAULT NULL,
  `derivative` varchar(255) DEFAULT NULL,
  `colour` varchar(255) DEFAULT NULL,
  `fuel_type` varchar(255) DEFAULT NULL,
  `engine_capacity_cc` int(10) DEFAULT NULL,
  `transmission_type` varchar(255) DEFAULT NULL,
  `vat_scheme` varchar(20) DEFAULT NULL,
  `tax_reference_11` varchar(20) DEFAULT NULL,
  `tax_reference_12` varchar(20) DEFAULT NULL,
  `number_of_previous_keepers` int(10) DEFAULT NULL,
  `purchase_vrm` varchar(10) DEFAULT NULL,
  `purchase_date` date DEFAULT NULL,
  `purchase_price_estimated` numeric(10,2) NULL DEFAULT NULL,
  `purchase_mileage` int(10) NULL DEFAULT NULL,
  `purchase_source` varchar(255) DEFAULT NULL,
  `purchase_channel` varchar(255) DEFAULT NULL,
  `purchase_event_type` varchar(255) DEFAULT NULL,
  `purchase_event_timestamp` timestamp DEFAULT NULL,
  `purchase_location` varchar(255) DEFAULT NULL,
  `ownership_method` varchar(255) NULL DEFAULT NULL,
  `ownership_owner` varchar(255) NULL DEFAULT NULL,
  `ownership_model` varchar(255) NULL DEFAULT NULL,
  `purchase_status` varchar(255) DEFAULT NULL,
  `purchase_currency` varchar(50) DEFAULT NULL,
  `purchase_price_gross` numeric(10,2) NULL DEFAULT NULL,
  `purchase_price_vat` numeric(10,2) NULL DEFAULT NULL,
  `planned_prep_centre` varchar(255) DEFAULT NULL,
  `is_purchase_auto_release` tinyint(1) DEFAULT NULL,
  `courtesy_vehicle_location` varchar(100) DEFAULT NULL,
  `netsuite_first_payment_date` date DEFAULT NULL,
  `netsuite_last_payment_date` date DEFAULT NULL,
  `netsuite_total_payments` int(10) DEFAULT NULL,
  `netsuite_total_amount` numeric(10,2) NULL DEFAULT NULL,
  `planned_arrive_at` timestamp NULL DEFAULT NULL,
  `planned_arrival_hub` varchar(50) DEFAULT NULL,
  `planned_arrival_ds` varchar(255) DEFAULT NULL,
  `planned_arrival_type` varchar(50) DEFAULT NULL,
  `first_seen_in_cpc_at` timestamp NULL DEFAULT NULL,
  `first_seen_in_prep_centre_at` timestamp NULL DEFAULT NULL,
  `first_seen_in_prep_centre` varchar(255) NULL DEFAULT NULL,
  `is_verified` tinyint(1) NULL DEFAULT NULL,
  `is_exported` tinyint(1) NULL DEFAULT NULL,
  `is_imported` tinyint(1) NULL DEFAULT NULL,
  `is_stolen` tinyint(1) NULL DEFAULT NULL,
  `is_scrapped` tinyint(1) NULL DEFAULT NULL,
  `is_on_risk_register` tinyint(1) NULL DEFAULT NULL,
  `has_mileage_issues` tinyint(1) NULL DEFAULT NULL,
  `has_mot_mileage_issues` tinyint(1) NULL DEFAULT NULL,
  `has_outstanding_finance` tinyint(1) NULL DEFAULT NULL,
  `has_outstanding_trade_finance` tinyint(1) NULL DEFAULT NULL,
  `has_outstanding_private_finance` tinyint(1) NULL DEFAULT NULL,
  `mot_expiry_date` date NULL DEFAULT NULL,
  `mot_mileage` int(10) NULL DEFAULT NULL,
  `tax_expiry_date` date NULL DEFAULT NULL,
  `insurance_write_off_category` varchar(50) NULL DEFAULT NULL,
  `ams_status` varchar(50) NULL DEFAULT NULL,
  `ams_serial_id` int(10) NULL DEFAULT NULL,
  `ams_vrm` varchar(10) NULL DEFAULT NULL,
  `ams_vin` varchar(20) NULL DEFAULT NULL,
  `ams_make` varchar(255) DEFAULT NULL,
  `ams_model` varchar(255) DEFAULT NULL,
  `ams_derivative` varchar(255) DEFAULT NULL,
  `ams_colour` varchar(255) DEFAULT NULL,
  `ams_vat_scheme` varchar(10) NULL DEFAULT NULL,
  `ams_mileage` int(10) NULL DEFAULT NULL,
  `ams_storage_site_code` varchar(50) NULL DEFAULT NULL,
  `ams_invoice_number` varchar(50) NULL DEFAULT NULL,
  `ams_invoice_date` date NULL DEFAULT NULL,
  `ams_location` varchar(255) NULL DEFAULT NULL,
  `ams_finance_status` varchar(50) NULL DEFAULT NULL,
  `ams_is_retail` tinyint(1) NULL DEFAULT NULL,
  `ams_is_subscription` tinyint(1) NULL DEFAULT NULL,
  `ams_updated_at` timestamp NULL DEFAULT NULL,
  `ams_has_mileage`  tinyint(1) NULL DEFAULT NULL,
  `ams_has_vehicle_details`  tinyint(1) NULL DEFAULT NULL,
  `ams_has_invoice` tinyint(1) NULL DEFAULT NULL,
  `ams_has_location` tinyint(1) NULL DEFAULT NULL,
  `ams_purchase_date` date DEFAULT NULL,
  `ams_purchase_provider` varchar(255) DEFAULT NULL,
  `ams_purchase_location` varchar(255) DEFAULT NULL,
  `ams_purchase_price_gross` numeric(10,2) NULL DEFAULT NULL,
  `ams_purchase_vat` numeric(10,2) NULL DEFAULT NULL,
  `asset_finance_status` varchar(50) NULL DEFAULT NULL,
  `asset_finance_provider` varchar(50) NULL DEFAULT NULL,
  `asset_finance_latest_lender` varchar(50) NULL DEFAULT NULL,
  `asset_finance_accepted_on` date NULL DEFAULT NULL,
  `asset_finance_removed_on` date NULL DEFAULT NULL,
  `asset_finance_rejected_on` date NULL DEFAULT NULL,
  `asset_finance_amount` numeric(10, 2) NULL DEFAULT NULL,
  `asset_finance_invoice_self_billing` varchar(50) NULL DEFAULT NULL,
  `asset_finance_invoice_upfront_vat` varchar(50) NULL DEFAULT NULL,
  `asset_finance_rejection_code` varchar(50) NULL DEFAULT NULL,
  `asset_finance_rejection_reason` varchar(255) NULL DEFAULT NULL,
  `merchandising_is_retail` tinyint(1) NULL DEFAULT NULL,
  `merchandising_is_subscription` tinyint(1) NULL DEFAULT NULL,
  `merchandising_is_auction` tinyint(1) NULL DEFAULT NULL,
  `merchandising_is_scrappage` tinyint(1) NULL DEFAULT NULL,
  `merchandising_saleable_from_date` date NULL DEFAULT NULL,
  `website_status` varchar(255) DEFAULT NULL,
  `website_status_updated_at` timestamp NULL DEFAULT NULL,
  `publish_vrm` varchar(10) DEFAULT NULL,
  `publish_updated_at` timestamp NULL DEFAULT NULL,
  `publish_inventory_id` varchar(50) DEFAULT NULL,
  `publish_has_price` tinyint(1) NULL DEFAULT NULL,
  `publish_has_finance_quote` tinyint(1) NULL DEFAULT NULL,
  `publish_has_vehicle_data` tinyint(1) NULL DEFAULT NULL,
  `publish_has_verified_features` tinyint(1) NULL DEFAULT NULL,
  `publish_has_photography` tinyint(1) NULL DEFAULT NULL,
  `publish_has_vat_scheme` tinyint(1) NULL DEFAULT NULL,
  `publish_has_v5c` tinyint(1) NULL DEFAULT NULL,
  `publish_has_passed_provenance_checks` tinyint(1) NULL DEFAULT NULL,
  `publish_is_purchased` tinyint(1) NULL DEFAULT NULL,
  `publish_bca_state` varchar(255) DEFAULT NULL,
  `publish_is_sold` tinyint(1) NULL DEFAULT NULL,
  `publish_state` varchar(255) DEFAULT NULL,
  `withdrawn_category` varchar(255) DEFAULT NULL,
  `withdrawn_reason` varchar(255) DEFAULT NULL,
  `withdrawn_by` varchar(255) DEFAULT NULL,
  `withdrawn_at` timestamp NULL DEFAULT NULL,
  `withdrawal_updated_by` varchar(255) DEFAULT NULL,
  `withdrawal_updated_at` timestamp NULL DEFAULT NULL,
  `relisted_by` varchar(255) DEFAULT NULL,
  `relisted_at`  timestamp NULL DEFAULT NULL,
  `order_number` varchar(255) DEFAULT NULL,
  `order_status` varchar(255) DEFAULT NULL,
  `location` varchar(255) NULL DEFAULT NULL,
  `location_check_type` varchar(255) NULL DEFAULT NULL,
  `location_changed_at` timestamp NULL DEFAULT NULL,
  `location_registered_at` timestamp NULL DEFAULT NULL,
  `location_registered_by` varchar(255) NULL DEFAULT NULL,
  `location_registered_latitude` numeric(10, 6) DEFAULT NULL,
  `location_registered_longitude` numeric(10, 6) DEFAULT NULL,
  `location_registered_accuracy` numeric(10, 6) DEFAULT NULL,
  `looker_location_status` varchar(255) NULL DEFAULT NULL,
  `looker_location_notes` text NULL DEFAULT NULL,
  `looker_location_updated_by` varchar(255) NULL DEFAULT NULL,
  `looker_location_updated_at` timestamp NULL DEFAULT NULL,
  `dotw_location` varchar(255) NULL DEFAULT NULL,
  `dotw_from_date` date NULL DEFAULT NULL,
  `dotw_to_date` date NULL DEFAULT NULL,
  `v5c_due_date` date NULL DEFAULT NULL,
  `v5c_internal_status` varchar(255) NULL DEFAULT NULL,
  `v5c_notes` text NULL DEFAULT NULL,
  `v5c_updated_by` varchar(255) NULL DEFAULT NULL,
  `v5c_updated_at` timestamp NULL DEFAULT NULL,
  `inbound_purchase_override_status` varchar(100) NULL DEFAULT NULL,
  `inbound_purchase_request_date` date NULL DEFAULT NULL,
  `inbound_purchase_transit_provider` varchar(50) NULL DEFAULT NULL,
  `inbound_purchase_expected_arrival_date` date NULL DEFAULT NULL,
  `inbound_purchase_notes` text NULL DEFAULT NULL,
  `inbound_purchase_sfs_production_complete_date` date NULL DEFAULT NULL,
  `inbound_purchase_updated_by` varchar(255) NULL DEFAULT NULL,
  `inbound_purchase_updated_at` timestamp NULL DEFAULT NULL,
  `px_destination` varchar(50) NULL DEFAULT NULL,
  `px_auction_submission_date` date NULL DEFAULT NULL,
  `px_auction_site` varchar(50) NULL DEFAULT NULL,
  `px_updated_by` varchar(255) NULL DEFAULT NULL,
  `px_updated_at` timestamp NULL DEFAULT NULL,
  `inspection_vrm` varchar(10) DEFAULT NULL,
  `inspection_ev_charging_cables_type1` tinyint(1) DEFAULT NULL,
  `inspection_ev_charging_cables_type2` tinyint(1) DEFAULT NULL,
  `inspection_ev_charging_cables_chademo` tinyint(1) DEFAULT NULL,
  `inspection_ev_charging_cables_ccs` tinyint(1) DEFAULT NULL,
  `inspection_ev_charging_cables_three_pin` tinyint(1) DEFAULT NULL,
  `inspection_ev_charging_cables_extension` tinyint(1) DEFAULT NULL,
  `inspection_make` varchar(50) DEFAULT NULL,
  `inspection_model` varchar(255) DEFAULT NULL,
  `inspection_mileage` int(10) DEFAULT NULL,
  `inspection_fuel_type` varchar(50) DEFAULT NULL,
  `inspection_transmission` varchar(50) DEFAULT NULL,
  `inspection_body_style` varchar(50) DEFAULT NULL,
  `inspection_number_of_doors` varchar(20) DEFAULT NULL,
  `inspection_trim` varchar(255) DEFAULT NULL,
  `inspection_colour` varchar(50) DEFAULT NULL,
  `inspection_paint_type` varchar(50) DEFAULT NULL,
  `inspection_air_conditioning` tinyint(1) DEFAULT NULL,
  `inspection_climate_control` tinyint(1) DEFAULT NULL,
  `inspection_bluetooth` tinyint(1) DEFAULT NULL,
  `inspection_apple_car_play` tinyint(1) DEFAULT NULL,
  `inspection_cd_player` tinyint(1) DEFAULT NULL,
  `inspection_parking_sensors` tinyint(1) DEFAULT NULL,
  `inspection_rear_parking_sensors` tinyint(1) DEFAULT NULL,
  `inspection_front_and_rear_parking_sensors` tinyint(1) DEFAULT NULL,
  `inspection_xenon_headlights` tinyint(1) DEFAULT NULL,
  `inspection_heated_seats` tinyint(1) DEFAULT NULL,
  `inspection_heated_front_seats` tinyint(1) DEFAULT NULL,
  `inspection_heated_rear_seats` tinyint(1) DEFAULT NULL,
  `inspection_heated_steering_wheel` tinyint(1) DEFAULT NULL,
  `inspection_privacy_glass` tinyint(1) DEFAULT NULL,
  `inspection_electric_front_seats` tinyint(1) DEFAULT NULL,
  `inspection_driver_seat_memory` tinyint(1) DEFAULT NULL,
  `inspection_isofix_fittings` tinyint(1) DEFAULT NULL,
  `inspection_heated_windscreen` tinyint(1) DEFAULT NULL,
  `inspection_sunroof` tinyint(1) DEFAULT NULL,
  `inspection_panoramic_roof` tinyint(1) DEFAULT NULL,
  `inspection_keyless_entry` tinyint(1) DEFAULT NULL,
  `inspection_keyless_start` tinyint(1) DEFAULT NULL,
  `inspection_heads_up_display` tinyint(1) DEFAULT NULL,
  `inspection_auto_start_stop` tinyint(1) DEFAULT NULL,
  `inspection_virtual_cockpit_dash` tinyint(1) DEFAULT NULL,
  `inspection_alloy_wheels` tinyint(1) DEFAULT NULL,
  `inspection_alloy_wheels_size_inches` int(10) DEFAULT NULL,
  `inspection_cruise_control` tinyint(1) DEFAULT NULL,
  `inspection_adaptive_cruise_control` tinyint(1) DEFAULT NULL,
  `inspection_active_cruise_control` tinyint(1) DEFAULT NULL,
  `inspection_dab_radio` tinyint(1) DEFAULT NULL,
  `inspection_towbar` varchar(50) DEFAULT NULL,
  `inspection_dvd_player` tinyint(1) DEFAULT NULL,
  `inspection_rear_entertainment_system_or_dvd_player` tinyint(1) DEFAULT NULL,
  `inspection_paddle_shift` tinyint(1) DEFAULT NULL,
  `inspection_parking_camera` tinyint(1) DEFAULT NULL,
  `inspection_rear_parking_camera` tinyint(1) DEFAULT NULL,
  `inspection_self_parking` tinyint(1) DEFAULT NULL,
  `inspection_satellite_navigation` varchar(255) DEFAULT NULL,
  `inspection_premium_sound_system` tinyint(1) DEFAULT NULL,
  `inspection_lane_departure_warning` tinyint(1) DEFAULT NULL,
  `inspection_additional_unexpected_damage` varchar(20) DEFAULT NULL,
  `inspection_correct_slam_panel_fitted` varchar(20) DEFAULT NULL,
  `inspection_detachable_towbar_keys_present_and_correct` varchar(20) DEFAULT NULL,
  `inspection_satellite_navigation_working` varchar(20) DEFAULT NULL,
  `inspection_sd_card_present_and_correct` varchar(20) DEFAULT NULL,
  `inspection_number_of_functioning_keys` smallint(5) DEFAULT NULL,
  `inspection_number_of_key_blades_present` smallint(5) DEFAULT NULL,
  `inspection_aerial_present` tinyint(1) DEFAULT NULL,
  `inspection_alloy_wheels_polished` tinyint(1) DEFAULT NULL,
  `inspection_alloy_wheels_painted` tinyint(1) DEFAULT NULL,
  `inspection_compressor_present` tinyint(1) DEFAULT NULL,
  `inspection_locking_wheel_nut_key_present` tinyint(1) DEFAULT NULL,
  `inspection_four_run_flat_tires_present` tinyint(1) DEFAULT NULL,
  `inspection_repair_kit_present` tinyint(1) DEFAULT NULL,
  `inspection_spare_wheel_present` tinyint(1) DEFAULT NULL,
  `inspection_parcel_shelf_or_load_cover_present` tinyint(1) DEFAULT NULL,
  `inspection_image_count_service_history` int(10) DEFAULT NULL,
  `inspection_updated_by` varchar(255) DEFAULT NULL,
  `inspection_updated_at` timestamp NULL DEFAULT NULL,
  `aged_inventory_assigned_to` varchar(255) DEFAULT NULL,
  `aged_inventory_expected_resolution_date` date DEFAULT NULL,
  `aged_inventory_notes` text DEFAULT NULL,
  `aged_inventory_updated_by` timestamp NULL DEFAULT NULL,
  `aged_inventory_updated_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`inventory_id`),
  KEY `vrm` (`vrm`),
  KEY `purchase_vrm` (`purchase_vrm`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;