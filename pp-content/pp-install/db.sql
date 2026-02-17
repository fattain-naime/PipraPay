-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Feb 16, 2026 at 02:44 PM
-- Server version: 10.9.8-MariaDB
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `piprapay`
--

-- --------------------------------------------------------

--
-- Table structure for table `pp_addon`
--

CREATE TABLE `pp_addon` (
  `id` int(11) NOT NULL,
  `addon_id` varchar(15) NOT NULL,
  `slug` varchar(40) NOT NULL DEFAULT '--',
  `name` varchar(150) NOT NULL DEFAULT '--',
  `status` enum('active','inactive','') NOT NULL DEFAULT 'active',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_addon_parameter`
--

CREATE TABLE `pp_addon_parameter` (
  `id` int(11) NOT NULL,
  `addon_id` varchar(15) NOT NULL,
  `option_name` varchar(50) NOT NULL,
  `value` text NOT NULL,
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_admin`
--

CREATE TABLE `pp_admin` (
  `id` int(11) NOT NULL,
  `a_id` varchar(15) NOT NULL,
  `full_name` text NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` text NOT NULL,
  `temp_password` varchar(255) NOT NULL DEFAULT '--',
  `reset_limit` int(11) NOT NULL DEFAULT 3,
  `status` enum('active','suspend','') NOT NULL DEFAULT 'active',
  `role` enum('admin','staff','') NOT NULL DEFAULT 'admin',
  `2fa_status` enum('enable','disable','') NOT NULL DEFAULT 'disable',
  `2fa_secret` varchar(20) NOT NULL DEFAULT '--',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_api`
--

CREATE TABLE `pp_api` (
  `id` int(11) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `name` varchar(120) NOT NULL,
  `api_key` varchar(60) NOT NULL,
  `expired_date` varchar(30) NOT NULL DEFAULT '--',
  `api_scopes` longtext NOT NULL,
  `status` enum('active','inactive','') NOT NULL DEFAULT 'active',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_balance_verification`
--

CREATE TABLE `pp_balance_verification` (
  `id` int(11) NOT NULL,
  `device_id` varchar(15) NOT NULL,
  `sender_key` varchar(15) NOT NULL,
  `type` enum('Personal','Agent','Merchant','') NOT NULL DEFAULT 'Personal',
  `current_balance` decimal(20,8) NOT NULL,
  `simslot` varchar(6) NOT NULL,
  `status` enum('active','inactive','') NOT NULL DEFAULT 'active',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_brands`
--

CREATE TABLE `pp_brands` (
  `id` int(11) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `favicon` varchar(255) NOT NULL DEFAULT '--',
  `logo` varchar(255) NOT NULL DEFAULT '--',
  `identify_name` varchar(50) NOT NULL DEFAULT 'Default',
  `name` varchar(120) NOT NULL DEFAULT '--',
  `support_email_address` varchar(120) NOT NULL DEFAULT '--',
  `support_phone_number` varchar(40) NOT NULL DEFAULT '--',
  `support_website` varchar(255) NOT NULL DEFAULT '--',
  `whatsapp_number` varchar(40) NOT NULL DEFAULT '--',
  `telegram` varchar(100) NOT NULL DEFAULT '--',
  `facebook_messenger` varchar(255) NOT NULL DEFAULT '--',
  `facebook_page` varchar(255) NOT NULL DEFAULT '--',
  `theme` varchar(20) NOT NULL DEFAULT 'twenty-six',
  `street_address` varchar(255) NOT NULL DEFAULT '--',
  `city_town` varchar(120) NOT NULL DEFAULT '--',
  `postal_code` varchar(20) NOT NULL DEFAULT '--',
  `country` varchar(80) NOT NULL DEFAULT '--',
  `timezone` varchar(64) NOT NULL DEFAULT 'Asia/Dhaka',
  `language` varchar(12) NOT NULL DEFAULT 'en',
  `currency_code` varchar(10) NOT NULL DEFAULT 'BDT',
  `autoExchange` enum('disabled','enabled','') NOT NULL DEFAULT 'disabled',
  `payment_tolerance` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `created_date` varchar(20) NOT NULL DEFAULT '--',
  `updated_date` varchar(20) NOT NULL DEFAULT '--'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_browser_log`
--

CREATE TABLE `pp_browser_log` (
  `id` int(11) NOT NULL,
  `a_id` varchar(15) NOT NULL,
  `cookie` varchar(40) NOT NULL,
  `browser` varchar(10) NOT NULL,
  `device` varchar(10) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `status` enum('active','expired','') NOT NULL DEFAULT 'active',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_currency`
--

CREATE TABLE `pp_currency` (
  `id` int(11) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `code` varchar(6) NOT NULL,
  `symbol` varchar(5) NOT NULL,
  `rate` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_customer`
--

CREATE TABLE `pp_customer` (
  `id` int(11) NOT NULL,
  `ref` varchar(15) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `name` text NOT NULL,
  `email` varchar(100) NOT NULL,
  `mobile` varchar(15) NOT NULL,
  `status` enum('active','suspend','') NOT NULL DEFAULT 'active',
  `suspend_reason` varchar(255) NOT NULL DEFAULT '--',
  `inserted_via` enum('manual','checkout','') NOT NULL DEFAULT 'manual',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_device`
--

CREATE TABLE `pp_device` (
  `id` int(11) NOT NULL,
  `d_id` varchar(40) NOT NULL,
  `device_id` varchar(15) NOT NULL,
  `otp` varchar(15) NOT NULL,
  `name` varchar(120) NOT NULL DEFAULT '--',
  `model` varchar(120) NOT NULL DEFAULT '--',
  `android_level` varchar(32) NOT NULL DEFAULT '--',
  `app_version` varchar(32) NOT NULL DEFAULT '--',
  `status` enum('processing','used','') NOT NULL DEFAULT 'processing',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL,
  `last_sync` varchar(20) NOT NULL DEFAULT '--'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_domain`
--

CREATE TABLE `pp_domain` (
  `id` int(11) NOT NULL,
  `domain` varchar(50) NOT NULL,
  `status` enum('active','inactive','') NOT NULL DEFAULT 'active',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_env`
--

CREATE TABLE `pp_env` (
  `id` int(11) NOT NULL,
  `brand_id` varchar(15) NOT NULL DEFAULT 'both',
  `option_name` varchar(50) NOT NULL,
  `value` text NOT NULL,
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_faq`
--

CREATE TABLE `pp_faq` (
  `id` int(11) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `title` text NOT NULL,
  `description` text NOT NULL,
  `status` enum('active','inactive','') NOT NULL DEFAULT 'active',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_gateways`
--

CREATE TABLE `pp_gateways` (
  `id` int(11) NOT NULL,
  `gateway_id` varchar(15) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `slug` varchar(40) NOT NULL DEFAULT '--',
  `name` varchar(120) NOT NULL DEFAULT '--',
  `display` varchar(120) NOT NULL DEFAULT '--',
  `logo` varchar(255) NOT NULL DEFAULT '--',
  `currency` varchar(6) NOT NULL,
  `min_allow` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `max_allow` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `fixed_discount` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `percentage_discount` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `fixed_charge` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `percentage_charge` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `primary_color` varchar(20) NOT NULL DEFAULT '--',
  `text_color` varchar(20) NOT NULL DEFAULT '--',
  `btn_color` varchar(20) NOT NULL DEFAULT '--',
  `btn_text_color` varchar(20) NOT NULL DEFAULT '--',
  `tab` enum('mfs','bank','global','') NOT NULL,
  `status` enum('active','inactive','') NOT NULL DEFAULT 'active',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_gateways_parameter`
--

CREATE TABLE `pp_gateways_parameter` (
  `id` int(11) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `gateway_id` varchar(15) NOT NULL,
  `option_name` varchar(50) NOT NULL,
  `value` text NOT NULL,
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_invoice`
--

CREATE TABLE `pp_invoice` (
  `id` int(11) NOT NULL,
  `ref` varchar(30) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `customer_info` longtext NOT NULL,
  `gateway_id` varchar(15) NOT NULL DEFAULT '--',
  `currency` varchar(10) NOT NULL,
  `due_date` varchar(30) NOT NULL DEFAULT '--',
  `shipping` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `status` enum('paid','unpaid','refunded','canceled') NOT NULL,
  `note` longtext NULL,
  `private_note` longtext NULL,
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_invoice_items`
--

CREATE TABLE `pp_invoice_items` (
  `id` int(11) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `invoice_id` varchar(30) NOT NULL,
  `description` varchar(255) NOT NULL DEFAULT '--',
  `amount` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `quantity` int(11) NOT NULL DEFAULT 0,
  `discount` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `vat` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_payment_link`
--

CREATE TABLE `pp_payment_link` (
  `id` int(11) NOT NULL,
  `ref` varchar(30) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `product_info` text NOT NULL,
  `amount` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `quantity` int(11) NOT NULL DEFAULT 0,
  `currency` varchar(10) NOT NULL,
  `expired_date` varchar(30) NOT NULL,
  `status` enum('active','inactive','') NOT NULL DEFAULT 'active',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_payment_link_field`
--

CREATE TABLE `pp_payment_link_field` (
  `id` int(11) NOT NULL,
  `paymentLinkID` varchar(30) NOT NULL,
  `formType` text NOT NULL,
  `fieldName` text NOT NULL,
  `value` text NOT NULL,
  `required` enum('true','false','') NOT NULL DEFAULT 'true',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_permission`
--

CREATE TABLE `pp_permission` (
  `id` int(11) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `a_id` varchar(15) NOT NULL,
  `permission` text NOT NULL,
  `status` enum('active','suspend','') NOT NULL DEFAULT 'active',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_sms_data`
--

CREATE TABLE `pp_sms_data` (
  `id` int(11) NOT NULL,
  `source` enum('app','web','') NOT NULL DEFAULT 'web',
  `device_id` varchar(15) NOT NULL,
  `sender` varchar(15) NOT NULL DEFAULT '--',
  `sender_key` varchar(15) NOT NULL,
  `simslot` varchar(16) NOT NULL DEFAULT '--',
  `number` varchar(20) NOT NULL DEFAULT '--',
  `amount` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `currency` varchar(10) NOT NULL DEFAULT '--',
  `trx_id` varchar(100) NOT NULL DEFAULT '--',
  `balance` varchar(70) NOT NULL DEFAULT '--',
  `message` longtext NULL,
  `reason` longtext NULL,
  `type` enum('Personal','Agent','Merchant','') NOT NULL DEFAULT 'Personal',
  `entry_type` enum('manual','automatic','') NOT NULL DEFAULT 'automatic',
  `edit_status` enum('done','pending','') NOT NULL DEFAULT 'pending',
  `status` enum('approved','awaiting-review','used','error') NOT NULL DEFAULT 'approved',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_transaction`
--

CREATE TABLE `pp_transaction` (
  `id` int(11) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `source` enum('invoice','payment-link','payment-link-default','api') NOT NULL DEFAULT 'api',
  `ref` varchar(30) NOT NULL,
  `customer_info` longtext NOT NULL,
  `amount` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `processing_fee` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `discount_amount` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `local_net_amount` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `currency` varchar(10) NOT NULL DEFAULT '--',
  `local_currency` varchar(10) DEFAULT NULL,
  `sender` varchar(50) NOT NULL DEFAULT '--',
  `trx_id` varchar(70) DEFAULT NULL,
  `trx_slip` longtext NULL,
  `gateway_id` varchar(50) NOT NULL DEFAULT '--',
  `sender_key` varchar(50) NOT NULL DEFAULT '--',
  `sender_type` varchar(11) NOT NULL DEFAULT '--',
  `source_info` longtext NULL,
  `metadata` longtext NULL,
  `status` enum('completed','pending','refunded','initiated','canceled') NOT NULL DEFAULT 'initiated',
  `return_url` varchar(500) NOT NULL DEFAULT '--',
  `webhook_url` varchar(500) NOT NULL DEFAULT '--',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  CONSTRAINT `chk_pp_transaction_amount_non_negative` CHECK (`amount` >= 0),
  CONSTRAINT `chk_pp_transaction_processing_fee_non_negative` CHECK (`processing_fee` >= 0),
  CONSTRAINT `chk_pp_transaction_discount_non_negative` CHECK (`discount_amount` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_webhook_log`
--

CREATE TABLE `pp_webhook_log` (
  `id` int(11) NOT NULL,
  `ref` varchar(15) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `payload` longtext NOT NULL,
  `url` varchar(500) NOT NULL,
  `attempts` int(11) NOT NULL DEFAULT 0,
  `response_body` longtext NULL,
  `http_code` varchar(10) NOT NULL DEFAULT '--',
  `status` enum('completed','pending','canceled','') NOT NULL DEFAULT 'pending',
  `created_date` varchar(20) NOT NULL,
  `updated_date` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_idempotency_keys`
--

CREATE TABLE `pp_idempotency_keys` (
  `id` bigint(20) unsigned NOT NULL,
  `scope` varchar(64) NOT NULL,
  `idempotency_key` varchar(128) NOT NULL,
  `request_hash` char(64) NOT NULL,
  `response_code` int(11) DEFAULT NULL,
  `response_body` longtext DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_payment_intents`
--

CREATE TABLE `pp_payment_intents` (
  `id` bigint(20) unsigned NOT NULL,
  `legacy_transaction_ref` varchar(30) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `source` enum('invoice','payment-link','payment-link-default','api') NOT NULL DEFAULT 'api',
  `amount` decimal(20,8) NOT NULL,
  `currency` char(3) NOT NULL,
  `customer_name` varchar(120) DEFAULT NULL,
  `customer_email` varchar(120) DEFAULT NULL,
  `customer_mobile` varchar(30) DEFAULT NULL,
  `idempotency_key` varchar(128) DEFAULT NULL,
  `metadata` longtext DEFAULT NULL,
  `status` enum('initiated','pending','completed','refunded','canceled') NOT NULL DEFAULT 'initiated',
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  CONSTRAINT `chk_pp_payment_intents_amount_positive` CHECK (`amount` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_payment_attempts`
--

CREATE TABLE `pp_payment_attempts` (
  `id` bigint(20) unsigned NOT NULL,
  `intent_id` bigint(20) unsigned NOT NULL,
  `gateway_id` varchar(50) DEFAULT NULL,
  `attempt_no` int(11) NOT NULL DEFAULT 1,
  `status` enum('initiated','pending','completed','failed','canceled') NOT NULL DEFAULT 'initiated',
  `provider_ref` varchar(120) DEFAULT NULL,
  `request_payload` longtext DEFAULT NULL,
  `response_payload` longtext DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_ledger_journal`
--

CREATE TABLE `pp_ledger_journal` (
  `id` bigint(20) unsigned NOT NULL,
  `event_type` varchar(50) NOT NULL,
  `external_ref` varchar(64) NOT NULL,
  `legacy_transaction_ref` varchar(30) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_ledger_entries`
--

CREATE TABLE `pp_ledger_entries` (
  `id` bigint(20) unsigned NOT NULL,
  `journal_id` bigint(20) unsigned NOT NULL,
  `legacy_transaction_ref` varchar(30) DEFAULT NULL,
  `account_code` varchar(64) NOT NULL,
  `entry_type` enum('debit','credit') NOT NULL,
  `amount` decimal(20,8) NOT NULL,
  `currency` char(3) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  CONSTRAINT `chk_pp_ledger_entries_amount_positive` CHECK (`amount` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_webhook_events`
--

CREATE TABLE `pp_webhook_events` (
  `id` bigint(20) unsigned NOT NULL,
  `provider` varchar(50) NOT NULL,
  `event_id` varchar(120) NOT NULL,
  `signature_hash` char(64) NOT NULL,
  `transaction_ref` varchar(30) DEFAULT NULL,
  `payload` longtext NOT NULL,
  `status` enum('received','processed','ignored','failed') NOT NULL DEFAULT 'received',
  `processed_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_audit_logs`
--

CREATE TABLE `pp_audit_logs` (
  `id` bigint(20) unsigned NOT NULL,
  `actor_type` varchar(20) NOT NULL,
  `actor_id` varchar(64) NOT NULL,
  `action` varchar(100) NOT NULL,
  `entity_name` varchar(80) NOT NULL,
  `entity_id` varchar(80) NOT NULL,
  `before_state` longtext DEFAULT NULL,
  `after_state` longtext DEFAULT NULL,
  `ip_address` varbinary(16) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_reconciliation_runs`
--

CREATE TABLE `pp_reconciliation_runs` (
  `id` bigint(20) unsigned NOT NULL,
  `run_ref` varchar(40) NOT NULL,
  `source_name` varchar(80) NOT NULL,
  `status` enum('running','completed','failed') NOT NULL DEFAULT 'running',
  `started_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `completed_at` datetime(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_reconciliation_items`
--

CREATE TABLE `pp_reconciliation_items` (
  `id` bigint(20) unsigned NOT NULL,
  `run_id` bigint(20) unsigned NOT NULL,
  `journal_id` bigint(20) unsigned DEFAULT NULL,
  `legacy_transaction_ref` varchar(30) DEFAULT NULL,
  `expected_amount` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `actual_amount` decimal(20,8) NOT NULL DEFAULT 0.00000000,
  `currency` char(3) NOT NULL,
  `status` enum('matched','mismatched','missing') NOT NULL DEFAULT 'matched',
  `notes` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pp_api_keys`
--

CREATE TABLE `pp_api_keys` (
  `id` bigint(20) unsigned NOT NULL,
  `api_id` int(11) NOT NULL,
  `brand_id` varchar(15) NOT NULL,
  `name` varchar(120) NOT NULL,
  `key_hash` char(64) NOT NULL,
  `key_prefix` varchar(12) NOT NULL,
  `scopes` longtext NOT NULL,
  `status` enum('active','inactive','revoked') NOT NULL DEFAULT 'active',
  `expired_at` datetime(6) DEFAULT NULL,
  `last_used_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pp_addon`
--
ALTER TABLE `pp_addon`
  ADD PRIMARY KEY (`id`),
  ADD KEY `addon_id` (`addon_id`,`status`,`created_date`,`updated_date`);

--
-- Indexes for table `pp_addon_parameter`
--
ALTER TABLE `pp_addon_parameter`
  ADD PRIMARY KEY (`id`),
  ADD KEY `addon_id` (`addon_id`,`option_name`,`created_date`,`updated_date`);

--
-- Indexes for table `pp_admin`
--
ALTER TABLE `pp_admin`
  ADD PRIMARY KEY (`id`),
  ADD KEY `a_id` (`a_id`,`email`),
  ADD KEY `username` (`username`),
  ADD KEY `created_date` (`created_date`,`updated_date`);

--
-- Indexes for table `pp_api`
--
ALTER TABLE `pp_api`
  ADD PRIMARY KEY (`id`),
  ADD KEY `brand_id` (`brand_id`,`api_key`,`created_date`,`updated_date`),
  ADD KEY `idx_pp_api_created_at` (`created_at`);

--
-- Indexes for table `pp_balance_verification`
--
ALTER TABLE `pp_balance_verification`
  ADD PRIMARY KEY (`id`),
  ADD KEY `device_id` (`device_id`,`sender_key`,`type`,`created_date`,`updated_date`),
  ADD KEY `simslot` (`simslot`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `pp_brands`
--
ALTER TABLE `pp_brands`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pp_brands_brand_id` (`brand_id`),
  ADD KEY `created_date` (`created_date`,`updated_date`),
  ADD KEY `identify_name` (`identify_name`),
  ADD KEY `autoExchange` (`autoExchange`);

--
-- Indexes for table `pp_browser_log`
--
ALTER TABLE `pp_browser_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `a_id` (`a_id`,`cookie`,`created_date`,`updated_date`),
  ADD KEY `created_date` (`created_date`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `pp_currency`
--
ALTER TABLE `pp_currency`
  ADD PRIMARY KEY (`id`),
  ADD KEY `brand_id` (`brand_id`,`code`,`symbol`);

--
-- Indexes for table `pp_customer`
--
ALTER TABLE `pp_customer`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ref` (`ref`,`brand_id`,`email`,`mobile`),
  ADD KEY `created_date` (`created_date`,`updated_date`),
  ADD KEY `status` (`status`,`inserted_via`),
  ADD KEY `idx_pp_customer_created_at` (`created_at`);

--
-- Indexes for table `pp_device`
--
ALTER TABLE `pp_device`
  ADD PRIMARY KEY (`id`),
  ADD KEY `device_id` (`device_id`),
  ADD KEY `created_date` (`created_date`,`updated_date`),
  ADD KEY `a_id` (`d_id`),
  ADD KEY `otp` (`otp`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `pp_domain`
--
ALTER TABLE `pp_domain`
  ADD PRIMARY KEY (`id`),
  ADD KEY `domain` (`domain`),
  ADD KEY `created_date` (`created_date`,`updated_date`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `pp_env`
--
ALTER TABLE `pp_env`
  ADD PRIMARY KEY (`id`),
  ADD KEY `option_name` (`option_name`),
  ADD KEY `brand_id` (`brand_id`),
  ADD KEY `created_date` (`created_date`,`updated_date`);

--
-- Indexes for table `pp_faq`
--
ALTER TABLE `pp_faq`
  ADD PRIMARY KEY (`id`),
  ADD KEY `brand_id` (`brand_id`,`created_date`,`updated_date`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `pp_gateways`
--
ALTER TABLE `pp_gateways`
  ADD PRIMARY KEY (`id`),
  ADD KEY `brand_id` (`brand_id`,`slug`),
  ADD KEY `g_id` (`gateway_id`),
  ADD KEY `created_date` (`created_date`,`updated_date`),
  ADD KEY `tab` (`tab`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `pp_gateways_parameter`
--
ALTER TABLE `pp_gateways_parameter`
  ADD PRIMARY KEY (`id`),
  ADD KEY `slug` (`gateway_id`,`option_name`),
  ADD KEY `brand_id` (`brand_id`),
  ADD KEY `created_date` (`created_date`,`updated_date`);

--
-- Indexes for table `pp_invoice`
--
ALTER TABLE `pp_invoice`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pp_invoice_ref` (`ref`),
  ADD KEY `idx_pp_invoice_brand_ref` (`brand_id`,`ref`),
  ADD KEY `created_date` (`created_date`,`updated_date`),
  ADD KEY `status` (`status`),
  ADD KEY `idx_pp_invoice_created_at` (`created_at`);

--
-- Indexes for table `pp_invoice_items`
--
ALTER TABLE `pp_invoice_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `invoice_id` (`invoice_id`),
  ADD KEY `brand_id` (`brand_id`),
  ADD KEY `created_date` (`created_date`,`updated_date`);

--
-- Indexes for table `pp_payment_link`
--
ALTER TABLE `pp_payment_link`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ref` (`ref`,`brand_id`,`created_date`,`updated_date`),
  ADD KEY `status` (`status`),
  ADD KEY `idx_pp_payment_link_created_at` (`created_at`);

--
-- Indexes for table `pp_payment_link_field`
--
ALTER TABLE `pp_payment_link_field`
  ADD PRIMARY KEY (`id`),
  ADD KEY `paymentLinkID` (`paymentLinkID`);

--
-- Indexes for table `pp_permission`
--
ALTER TABLE `pp_permission`
  ADD PRIMARY KEY (`id`),
  ADD KEY `brand_id` (`brand_id`,`a_id`,`created_date`,`updated_date`);

--
-- Indexes for table `pp_sms_data`
--
ALTER TABLE `pp_sms_data`
  ADD PRIMARY KEY (`id`),
  ADD KEY `device_id` (`sender_key`,`amount`,`trx_id`),
  ADD KEY `created_date` (`created_date`,`updated_date`),
  ADD KEY `number` (`number`),
  ADD KEY `balance` (`balance`),
  ADD KEY `device_id_2` (`device_id`),
  ADD KEY `sender` (`sender`),
  ADD KEY `source` (`source`),
  ADD KEY `type` (`type`,`entry_type`,`edit_status`,`status`);

--
-- Indexes for table `pp_transaction`
--
ALTER TABLE `pp_transaction`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pp_transaction_ref` (`ref`),
  ADD UNIQUE KEY `uq_pp_transaction_trx_id` (`trx_id`),
  ADD KEY `brand_id` (`brand_id`,`ref`,`trx_id`),
  ADD KEY `payment_method_id` (`gateway_id`,`sender_key`),
  ADD KEY `gateway_slug` (`sender_key`),
  ADD KEY `created_date` (`created_date`,`updated_date`),
  ADD KEY `sender` (`sender`),
  ADD KEY `source` (`source`,`status`),
  ADD KEY `sender_type` (`sender_type`),
  ADD KEY `idx_pp_transaction_created_at` (`created_at`),
  ADD KEY `idx_pp_transaction_status_created_at` (`status`,`created_at`);

--
-- Indexes for table `pp_webhook_log`
--
ALTER TABLE `pp_webhook_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ref` (`ref`),
  ADD KEY `brand_id` (`brand_id`),
  ADD KEY `idx_pp_webhook_log_created_at` (`created_at`);

--
-- Indexes for table `pp_idempotency_keys`
--
ALTER TABLE `pp_idempotency_keys`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_scope_key` (`scope`,`idempotency_key`),
  ADD KEY `idx_pp_idempotency_created_at` (`created_at`);

--
-- Indexes for table `pp_payment_intents`
--
ALTER TABLE `pp_payment_intents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pp_payment_intents_legacy_transaction_ref` (`legacy_transaction_ref`),
  ADD UNIQUE KEY `uq_pp_payment_intents_idempotency_key` (`idempotency_key`),
  ADD KEY `idx_pp_payment_intents_brand_status` (`brand_id`,`status`),
  ADD KEY `idx_pp_payment_intents_created_at` (`created_at`);

--
-- Indexes for table `pp_payment_attempts`
--
ALTER TABLE `pp_payment_attempts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pp_payment_attempts_intent` (`intent_id`,`attempt_no`),
  ADD KEY `idx_pp_payment_attempts_status` (`status`),
  ADD KEY `idx_pp_payment_attempts_provider_ref` (`provider_ref`);

--
-- Indexes for table `pp_ledger_journal`
--
ALTER TABLE `pp_ledger_journal`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pp_ledger_journal_event_ref` (`event_type`,`external_ref`),
  ADD KEY `idx_pp_ledger_journal_txn` (`legacy_transaction_ref`);

--
-- Indexes for table `pp_ledger_entries`
--
ALTER TABLE `pp_ledger_entries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pp_ledger_entries_journal` (`journal_id`),
  ADD KEY `idx_pp_ledger_entries_txn` (`legacy_transaction_ref`),
  ADD KEY `idx_pp_ledger_entries_account_currency` (`account_code`,`currency`);

--
-- Indexes for table `pp_webhook_events`
--
ALTER TABLE `pp_webhook_events`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pp_webhook_events_provider_event` (`provider`,`event_id`),
  ADD UNIQUE KEY `uq_pp_webhook_events_signature_hash` (`signature_hash`),
  ADD KEY `idx_pp_webhook_events_created_at` (`created_at`),
  ADD KEY `idx_pp_webhook_events_transaction_ref` (`transaction_ref`);

--
-- Indexes for table `pp_audit_logs`
--
ALTER TABLE `pp_audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pp_audit_entity_time` (`entity_name`,`entity_id`,`created_at`),
  ADD KEY `idx_pp_audit_actor_time` (`actor_type`,`actor_id`,`created_at`);

--
-- Indexes for table `pp_reconciliation_runs`
--
ALTER TABLE `pp_reconciliation_runs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pp_reconciliation_runs_run_ref` (`run_ref`),
  ADD KEY `idx_pp_reconciliation_runs_status` (`status`,`started_at`);

--
-- Indexes for table `pp_reconciliation_items`
--
ALTER TABLE `pp_reconciliation_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pp_reconciliation_items_run_status` (`run_id`,`status`),
  ADD KEY `idx_pp_reconciliation_items_txn` (`legacy_transaction_ref`),
  ADD KEY `idx_pp_reconciliation_items_journal` (`journal_id`);

--
-- Indexes for table `pp_api_keys`
--
ALTER TABLE `pp_api_keys`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pp_api_keys_key_hash` (`key_hash`),
  ADD KEY `idx_pp_api_keys_api_id` (`api_id`),
  ADD KEY `idx_pp_api_keys_brand_status` (`brand_id`,`status`),
  ADD KEY `idx_pp_api_keys_expired_at` (`expired_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `pp_addon`
--
ALTER TABLE `pp_addon`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_addon_parameter`
--
ALTER TABLE `pp_addon_parameter`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_admin`
--
ALTER TABLE `pp_admin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_api`
--
ALTER TABLE `pp_api`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_balance_verification`
--
ALTER TABLE `pp_balance_verification`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_brands`
--
ALTER TABLE `pp_brands`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_browser_log`
--
ALTER TABLE `pp_browser_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_currency`
--
ALTER TABLE `pp_currency`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_customer`
--
ALTER TABLE `pp_customer`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_device`
--
ALTER TABLE `pp_device`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_domain`
--
ALTER TABLE `pp_domain`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_env`
--
ALTER TABLE `pp_env`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_faq`
--
ALTER TABLE `pp_faq`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_gateways`
--
ALTER TABLE `pp_gateways`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_gateways_parameter`
--
ALTER TABLE `pp_gateways_parameter`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_invoice`
--
ALTER TABLE `pp_invoice`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_invoice_items`
--
ALTER TABLE `pp_invoice_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_payment_link`
--
ALTER TABLE `pp_payment_link`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_payment_link_field`
--
ALTER TABLE `pp_payment_link_field`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_permission`
--
ALTER TABLE `pp_permission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_sms_data`
--
ALTER TABLE `pp_sms_data`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_transaction`
--
ALTER TABLE `pp_transaction`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_webhook_log`
--
ALTER TABLE `pp_webhook_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_idempotency_keys`
--
ALTER TABLE `pp_idempotency_keys`
  MODIFY `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_payment_intents`
--
ALTER TABLE `pp_payment_intents`
  MODIFY `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_payment_attempts`
--
ALTER TABLE `pp_payment_attempts`
  MODIFY `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_ledger_journal`
--
ALTER TABLE `pp_ledger_journal`
  MODIFY `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_ledger_entries`
--
ALTER TABLE `pp_ledger_entries`
  MODIFY `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_webhook_events`
--
ALTER TABLE `pp_webhook_events`
  MODIFY `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_audit_logs`
--
ALTER TABLE `pp_audit_logs`
  MODIFY `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_reconciliation_runs`
--
ALTER TABLE `pp_reconciliation_runs`
  MODIFY `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_reconciliation_items`
--
ALTER TABLE `pp_reconciliation_items`
  MODIFY `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pp_api_keys`
--
ALTER TABLE `pp_api_keys`
  MODIFY `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT;

--
-- Constraints for fintech target schema v1
--
ALTER TABLE `pp_payment_intents`
  ADD CONSTRAINT `fk_pp_payment_intents_legacy_transaction_ref` FOREIGN KEY (`legacy_transaction_ref`) REFERENCES `pp_transaction` (`ref`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pp_payment_intents_brand_id` FOREIGN KEY (`brand_id`) REFERENCES `pp_brands` (`brand_id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `pp_payment_attempts`
  ADD CONSTRAINT `fk_pp_payment_attempts_intent` FOREIGN KEY (`intent_id`) REFERENCES `pp_payment_intents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `pp_ledger_journal`
  ADD CONSTRAINT `fk_pp_ledger_journal_transaction_ref` FOREIGN KEY (`legacy_transaction_ref`) REFERENCES `pp_transaction` (`ref`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `pp_ledger_entries`
  ADD CONSTRAINT `fk_pp_ledger_entries_journal` FOREIGN KEY (`journal_id`) REFERENCES `pp_ledger_journal` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pp_ledger_entries_transaction_ref` FOREIGN KEY (`legacy_transaction_ref`) REFERENCES `pp_transaction` (`ref`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `pp_webhook_events`
  ADD CONSTRAINT `fk_pp_webhook_events_transaction_ref` FOREIGN KEY (`transaction_ref`) REFERENCES `pp_transaction` (`ref`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `pp_reconciliation_items`
  ADD CONSTRAINT `fk_pp_reconciliation_items_run` FOREIGN KEY (`run_id`) REFERENCES `pp_reconciliation_runs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pp_reconciliation_items_journal` FOREIGN KEY (`journal_id`) REFERENCES `pp_ledger_journal` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pp_reconciliation_items_transaction_ref` FOREIGN KEY (`legacy_transaction_ref`) REFERENCES `pp_transaction` (`ref`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `pp_api_keys`
  ADD CONSTRAINT `fk_pp_api_keys_api_id` FOREIGN KEY (`api_id`) REFERENCES `pp_api` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pp_api_keys_brand_id` FOREIGN KEY (`brand_id`) REFERENCES `pp_brands` (`brand_id`) ON DELETE RESTRICT ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
