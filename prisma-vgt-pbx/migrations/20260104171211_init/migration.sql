-- CreateTable
CREATE TABLE "auth_group" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(150) NOT NULL,

    CONSTRAINT "auth_group_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_permission" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "codename" VARCHAR(100) NOT NULL,

    CONSTRAINT "auth_permission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_group_permissions" (
    "id" BIGSERIAL NOT NULL,
    "groupId" INTEGER NOT NULL,
    "permissionId" INTEGER NOT NULL,

    CONSTRAINT "auth_group_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_tenant" (
    "id" VARCHAR(50) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" VARCHAR(500),
    "firebaseTenantId" VARCHAR(50),
    "disabled" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "auth_tenant_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_user" (
    "uid" VARCHAR(50) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "displayName" VARCHAR(100),
    "firstName" VARCHAR(150),
    "lastName" VARCHAR(150),
    "avatar" VARCHAR(255),
    "phoneNumber" VARCHAR(20),
    "disabled" BOOLEAN NOT NULL DEFAULT false,
    "lastSignInAt" TIMESTAMP(3),
    "tenantId" VARCHAR(50) NOT NULL DEFAULT 'default',

    CONSTRAINT "auth_user_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "invite" (
    "id" VARCHAR(50) NOT NULL DEFAULT 'inv_' || gen_random_uuid(),
    "email" VARCHAR(255) NOT NULL,
    "domainId" UUID NOT NULL,
    "groupId" INTEGER NOT NULL,
    "token" VARCHAR(100) NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "createdBy" VARCHAR(50) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "invite_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "subscription" (
    "id" VARCHAR(50) NOT NULL DEFAULT 'sub_' || gen_random_uuid(),
    "domainId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "displayName" VARCHAR(200),
    "logo" VARCHAR(255),
    "plan" VARCHAR(20) NOT NULL DEFAULT 'basic',
    "maxUsers" INTEGER NOT NULL DEFAULT 5,
    "maxExtensions" INTEGER NOT NULL DEFAULT 10,
    "stripeCustomerId" VARCHAR(100),
    "stripeSubscriptionId" VARCHAR(100),
    "billingEmail" VARCHAR(255),
    "billingCycle" VARCHAR(20) NOT NULL DEFAULT 'monthly',
    "trialEndsAt" TIMESTAMP(3),
    "currentPeriodStart" TIMESTAMP(3),
    "currentPeriodEnd" TIMESTAMP(3),
    "canceledAt" TIMESTAMP(3),
    "status" VARCHAR(20) NOT NULL DEFAULT 'trialing',

    CONSTRAINT "subscription_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_user_groups" (
    "id" BIGSERIAL NOT NULL,
    "uid" TEXT NOT NULL,
    "groupId" INTEGER NOT NULL,

    CONSTRAINT "auth_user_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_user_user_permissions" (
    "id" BIGSERIAL NOT NULL,
    "uid" TEXT NOT NULL,
    "permissionId" INTEGER NOT NULL,

    CONSTRAINT "auth_user_user_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "authtoken_token" (
    "key" VARCHAR(40) NOT NULL,
    "created" TIMESTAMPTZ(6) NOT NULL,
    "uid" VARCHAR(50) NOT NULL,

    CONSTRAINT "authtoken_token_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "pbx_access_control_nodes" (
    "id" UUID NOT NULL,
    "type" VARCHAR(8) NOT NULL,
    "cidr" VARCHAR(64),
    "domain" VARCHAR(64),
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "access_control_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_access_control_nodes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_access_controls" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "default" VARCHAR(8) NOT NULL,
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,

    CONSTRAINT "pbx_access_controls_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_auto_report" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64),
    "title" VARCHAR(128),
    "message" TEXT,
    "footer" VARCHAR(256),
    "recipients" TEXT NOT NULL,
    "frequency" VARCHAR(8),
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(128),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,

    CONSTRAINT "pbx_auto_report_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_auto_report_section" (
    "id" UUID NOT NULL,
    "title" VARCHAR(128),
    "sequence" DECIMAL(3,0) NOT NULL,
    "sql" TEXT NOT NULL,
    "message" TEXT,
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(128),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "auto_report_id" UUID,

    CONSTRAINT "pbx_auto_report_section_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_bridges" (
    "id" UUID NOT NULL,
    "name" VARCHAR(32) NOT NULL,
    "destination" VARCHAR(256) NOT NULL,
    "disabled" BOOLEAN NOT NULL DEFAULT false,
    "description" VARCHAR(64),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,

    CONSTRAINT "pbx_bridges_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_call_block" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64),
    "number" VARCHAR(64),
    "block_count" DECIMAL(6,0) NOT NULL,
    "app" VARCHAR(32),
    "data" VARCHAR(256),
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(64),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,

    CONSTRAINT "pbx_call_block_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_call_centre_agents" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64),
    "agent_type" VARCHAR(16),
    "call_timeout" DECIMAL(3,0) NOT NULL,
    "agent_id" VARCHAR(64),
    "agent_pin" VARCHAR(16) NOT NULL,
    "contact" VARCHAR(256),
    "status" VARCHAR(32),
    "data" VARCHAR(64) NOT NULL,
    "no_answer_delay_time" DECIMAL(3,0) NOT NULL,
    "max_no_answer" DECIMAL(3,0) NOT NULL,
    "wrap_up_time" DECIMAL(3,0) NOT NULL,
    "reject_delay_time" DECIMAL(3,0) NOT NULL,
    "busy_delay_time" DECIMAL(3,0) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,
    "user_uuid" UUID,

    CONSTRAINT "pbx_call_centre_agents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_call_centre_queues" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64),
    "extension" VARCHAR(32) NOT NULL,
    "greeting" VARCHAR(256),
    "strategy" VARCHAR(32),
    "moh_sound" VARCHAR(256),
    "record_template" VARCHAR(256),
    "time_base_score" VARCHAR(16),
    "max_wait_time" DECIMAL(3,0) NOT NULL,
    "max_wait_time_na" DECIMAL(3,0) NOT NULL,
    "max_wait_time_natr" DECIMAL(3,0) NOT NULL,
    "timeout_action" VARCHAR(256),
    "tier_rules_apply" VARCHAR(8) NOT NULL,
    "tier_rule_wait_sec" DECIMAL(3,0) NOT NULL,
    "tier_rule_wm_level" VARCHAR(8) NOT NULL,
    "tier_rule_nanw" VARCHAR(8) NOT NULL,
    "discard_abndnd_after" DECIMAL(4,0) NOT NULL,
    "abndnd_resume_allowed" VARCHAR(8) NOT NULL,
    "cid_name_prefix" VARCHAR(32),
    "announce_sound" VARCHAR(256),
    "announce_frequency" DECIMAL(3,0),
    "cc_exit_keys" VARCHAR(8),
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(64),
    "dialplan_id" UUID,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,
    "wb_aban_crit_level" DECIMAL(3,0) NOT NULL,
    "wb_aban_warn_level" DECIMAL(3,0) NOT NULL,
    "wb_agents_per_row" DECIMAL(3,0) NOT NULL,
    "wb_show_agents" VARCHAR(8) NOT NULL,
    "wb_wait_crit_level" DECIMAL(3,0) NOT NULL,
    "wb_wait_warn_level" DECIMAL(3,0) NOT NULL,

    CONSTRAINT "pbx_call_centre_queues_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_call_centre_tiers" (
    "id" UUID NOT NULL,
    "tier_level" DECIMAL(4,0) NOT NULL,
    "tier_position" DECIMAL(4,0) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "agent_id_id" UUID NOT NULL,
    "queue_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_call_centre_tiers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_call_flows" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64),
    "extension" VARCHAR(32) NOT NULL,
    "feature_code" VARCHAR(8) NOT NULL,
    "status" VARCHAR(8) NOT NULL,
    "pin_number" VARCHAR(16),
    "label" VARCHAR(32),
    "sound" VARCHAR(254),
    "app" VARCHAR(32),
    "data" VARCHAR(256),
    "alternate_label" VARCHAR(32),
    "alternate_sound" VARCHAR(254),
    "alternate_app" VARCHAR(32),
    "alternate_data" VARCHAR(256),
    "context" VARCHAR(128),
    "description" VARCHAR(64),
    "dialplan_id" UUID,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,

    CONSTRAINT "pbx_call_flows_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_call_recordings" (
    "id" UUID NOT NULL,
    "filename" TEXT NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "year" VARCHAR(8) NOT NULL,
    "month" VARCHAR(8) NOT NULL,
    "day" VARCHAR(8) NOT NULL,
    "description" VARCHAR(128),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,
    "filestore" VARCHAR(128) NOT NULL,

    CONSTRAINT "pbx_call_recordings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_call_timeline" (
    "id" UUID NOT NULL,
    "core_uuid" UUID NOT NULL,
    "hostname" VARCHAR(128),
    "switchame" VARCHAR(128),
    "switch_ipv4" VARCHAR(16),
    "switch_ipv6" VARCHAR(64),
    "call_uuid" UUID,
    "event_name" VARCHAR(64) NOT NULL,
    "event_subclass" VARCHAR(64),
    "event_date_local" VARCHAR(64),
    "event_epoch" DECIMAL(32,0) NOT NULL,
    "event_sequence" DECIMAL(32,0) NOT NULL,
    "event_calling_file" VARCHAR(64),
    "event_calling_function" VARCHAR(64),
    "direction" VARCHAR(16),
    "other_leg_direction" VARCHAR(16),
    "context" VARCHAR(128),
    "other_leg_context" VARCHAR(128),
    "hit_dialplan" VARCHAR(8) NOT NULL,
    "caller_user_name" VARCHAR(32),
    "caller_ani" VARCHAR(32),
    "other_leg_user_name" VARCHAR(32),
    "caller_uuid" UUID,
    "other_leg_caller_uuid" UUID,
    "channel_name" VARCHAR(256),
    "channel_state" VARCHAR(32),
    "channel_call_state" VARCHAR(32),
    "answer_state" VARCHAR(32),
    "bridge_channel" VARCHAR(256),
    "caller_id_name" VARCHAR(32),
    "other_leg_caller_id_name" VARCHAR(32),
    "caller_id_number" VARCHAR(32),
    "other_leg_caller_id_number" VARCHAR(32),
    "caller_destination" VARCHAR(32),
    "other_leg_caller_destination" VARCHAR(32),
    "network_addr" VARCHAR(64),
    "other_leg_network_addr" VARCHAR(64),
    "created_time" DECIMAL(32,0) NOT NULL,
    "other_leg_created_time" DECIMAL(32,0) NOT NULL,
    "answered_time" DECIMAL(32,0) NOT NULL,
    "other_leg_answered_time" DECIMAL(32,0) NOT NULL,
    "progress_time" DECIMAL(32,0) NOT NULL,
    "other_leg_progress_time" DECIMAL(32,0) NOT NULL,
    "progress_media_time" DECIMAL(32,0) NOT NULL,
    "other_leg_progress_media_time" DECIMAL(32,0) NOT NULL,
    "hangup_time" DECIMAL(32,0) NOT NULL,
    "other_leg_hangup_time" DECIMAL(32,0) NOT NULL,
    "transfer_time" DECIMAL(32,0) NOT NULL,
    "other_leg_transfer_time" DECIMAL(32,0) NOT NULL,
    "resurrect_time" DECIMAL(32,0) NOT NULL,
    "other_leg_resurrect_time" DECIMAL(32,0) NOT NULL,
    "bridged_time" DECIMAL(32,0) NOT NULL,
    "other_leg_bridged_time" DECIMAL(32,0) NOT NULL,
    "last_hold_time" DECIMAL(32,0) NOT NULL,
    "other_leg_last_hold_time" DECIMAL(32,0) NOT NULL,
    "hold_accu_time" DECIMAL(32,0) NOT NULL,
    "other_leg_hold_accu_time" DECIMAL(32,0) NOT NULL,
    "application" VARCHAR(32),
    "application_uuid" UUID,
    "application_data" VARCHAR(256),
    "application_status" VARCHAR(32),
    "application_file_path" VARCHAR(256),
    "application_seconds" DECIMAL(32,0),
    "transfer_source" VARCHAR(256),
    "cc_side" VARCHAR(16),
    "cc_queue" UUID,
    "cc_action" VARCHAR(32),
    "cc_count" DECIMAL(32,0) NOT NULL,
    "cc_member_joining_time" DECIMAL(32,0) NOT NULL,
    "cc_member_leaving_time" DECIMAL(32,0) NOT NULL,
    "cc_cause" VARCHAR(32),
    "cc_hangup_cause" VARCHAR(32),
    "cc_cancel_reason" VARCHAR(32),
    "cc_member_uuid" UUID,
    "cc_member_session_uuid" UUID,
    "cc_member_caller_id_name" VARCHAR(32),
    "cc_member_caller_id_number" VARCHAR(32),
    "cc_agent" VARCHAR(128),
    "cc_agent_uuid" UUID,
    "cc_agent_system" VARCHAR(32),
    "cc_agent_type" VARCHAR(32),
    "cc_agent_state" VARCHAR(32),
    "cc_agent_called_time" DECIMAL(32,0) NOT NULL,
    "cc_agent_answered_time" DECIMAL(32,0) NOT NULL,
    "dtmf_digit" VARCHAR(8),
    "dtmf_duration" DECIMAL(5,0) NOT NULL,
    "dtmf_source" VARCHAR(32),
    "cf_name" VARCHAR(256),
    "cf_action" VARCHAR(32),
    "cf_uuid" UUID,
    "cf_domain" VARCHAR(128),
    "cf_size" DECIMAL(5,0) NOT NULL,
    "cf_ghosts" DECIMAL(5,0) NOT NULL,
    "cf_profile_name" VARCHAR(64),
    "cf_member_type" VARCHAR(32),
    "cf_member_id" VARCHAR(32),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_id_id" UUID,
    "application_action" VARCHAR(32),
    "application_name" VARCHAR(64),
    "general_error" VARCHAR(64),
    "other_leg_unique_id" UUID,
    "unique_id" UUID,

    CONSTRAINT "pbx_call_timeline_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_cc_agent_status_log" (
    "id" UUID NOT NULL,
    "status" VARCHAR(32),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "agent_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_cc_agent_status_log_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_conference_centres" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64),
    "extension" VARCHAR(32) NOT NULL,
    "greeting" VARCHAR(254),
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(64),
    "dialplan_id" UUID,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,

    CONSTRAINT "pbx_conference_centres_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_conference_control_details" (
    "id" UUID NOT NULL,
    "digits" VARCHAR(8) NOT NULL,
    "action" VARCHAR(64) NOT NULL,
    "data" VARCHAR(254),
    "enabled" VARCHAR(8) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "conf_ctrl_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_conference_control_details_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_conference_controls" (
    "id" UUID NOT NULL,
    "name" VARCHAR(32) NOT NULL,
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(256),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,

    CONSTRAINT "pbx_conference_controls_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_conference_profile_params" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "value" VARCHAR(254),
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "conf_profile_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_conference_profile_params_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_conference_profiles" (
    "id" UUID NOT NULL,
    "name" VARCHAR(32) NOT NULL,
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,

    CONSTRAINT "pbx_conference_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_conference_room_users" (
    "id" UUID NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "c_room_id_id" UUID NOT NULL,
    "user_uuid" UUID,

    CONSTRAINT "pbx_conference_room_users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_conference_rooms" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64),
    "moderator_pin" VARCHAR(16) NOT NULL,
    "participant_pin" VARCHAR(16) NOT NULL,
    "max_members" DECIMAL(3,0) NOT NULL,
    "start_time" TIMESTAMPTZ(6),
    "stop_time" TIMESTAMPTZ(6),
    "record" VARCHAR(8) NOT NULL,
    "wait_mod" VARCHAR(8) NOT NULL,
    "announce" VARCHAR(8) NOT NULL,
    "sounds" VARCHAR(8) NOT NULL,
    "mute" VARCHAR(8) NOT NULL,
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(64),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "c_centre_id_id" UUID NOT NULL,
    "c_profile_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_conference_rooms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_conference_sessions" (
    "id" UUID NOT NULL,
    "caller_id_name" VARCHAR(128),
    "caller_id_number" VARCHAR(64),
    "profile" VARCHAR(32),
    "live" VARCHAR(8) NOT NULL,
    "recording" VARCHAR(256),
    "start" TIMESTAMPTZ(6),
    "end" TIMESTAMPTZ(6),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "c_room_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_conference_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_contacts" (
    "id" UUID NOT NULL,
    "fn" VARCHAR(254) NOT NULL,
    "family_name" VARCHAR(64) NOT NULL,
    "given_name" VARCHAR(64),
    "additional_name" VARCHAR(64),
    "honorific_prefix" VARCHAR(32),
    "honorific_suffix" VARCHAR(32),
    "nickname" VARCHAR(64),
    "timezone" VARCHAR(128),
    "notes" TEXT,
    "enabled" VARCHAR(8) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_id_id" UUID,
    "user_id_id" BIGINT,

    CONSTRAINT "pbx_contacts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_contacts_address" (
    "id" UUID NOT NULL,
    "post_office_box" VARCHAR(64),
    "extended_address" VARCHAR(128),
    "street_address" VARCHAR(128) NOT NULL,
    "locality" VARCHAR(128),
    "region" VARCHAR(128),
    "postal_code" VARCHAR(16) NOT NULL,
    "country_name" VARCHAR(128),
    "addr_type" VARCHAR(16) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "contact_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_contacts_address_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_contacts_category" (
    "id" UUID NOT NULL,
    "category" VARCHAR(64) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "contact_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_contacts_category_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_contacts_dates" (
    "id" UUID NOT NULL,
    "sig_date" DATE,
    "label" VARCHAR(64) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "contact_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_contacts_dates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_contacts_email" (
    "id" UUID NOT NULL,
    "email_type" VARCHAR(16) NOT NULL,
    "email" VARCHAR(1024) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "contact_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_contacts_email_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_contacts_geo" (
    "id" UUID NOT NULL,
    "geo_uri" VARCHAR(1024) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "contact_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_contacts_geo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_contacts_groups" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "contact_id_id" UUID NOT NULL,
    "group_id" INTEGER NOT NULL,

    CONSTRAINT "pbx_contacts_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_contacts_org" (
    "id" UUID NOT NULL,
    "organisation_name" VARCHAR(128) NOT NULL,
    "organisation_unit" VARCHAR(128) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "contact_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_contacts_org_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_contacts_tel" (
    "id" UUID NOT NULL,
    "tel_type" VARCHAR(32) NOT NULL,
    "number" VARCHAR(128) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "contact_id_id" UUID NOT NULL,
    "speed_dial" VARCHAR(16),

    CONSTRAINT "pbx_contacts_tel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_contacts_url" (
    "id" UUID NOT NULL,
    "url_uri" VARCHAR(1024) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "contact_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_contacts_url_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_default_settings" (
    "id" UUID NOT NULL,
    "app_uuid" UUID,
    "category" VARCHAR(32) NOT NULL,
    "subcategory" VARCHAR(64) NOT NULL,
    "value_type" VARCHAR(32) NOT NULL,
    "value" VARCHAR(254),
    "sequence" DECIMAL(11,0) NOT NULL,
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(128),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,

    CONSTRAINT "pbx_default_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_device_keys" (
    "id" UUID NOT NULL,
    "category" VARCHAR(16) NOT NULL,
    "key_id" DECIMAL(11,0) NOT NULL,
    "key_type" VARCHAR(64) NOT NULL,
    "line" DECIMAL(3,0) NOT NULL,
    "value" VARCHAR(254),
    "extension" VARCHAR(64),
    "protected" VARCHAR(8) NOT NULL,
    "label" VARCHAR(64),
    "icon" VARCHAR(64),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "device_id" UUID NOT NULL,

    CONSTRAINT "pbx_device_keys_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_device_lines" (
    "id" UUID NOT NULL,
    "line_number" DECIMAL(3,0) NOT NULL,
    "server_address" VARCHAR(254),
    "server_address_primary" VARCHAR(254),
    "server_address_secondary" VARCHAR(254),
    "outbound_proxy_primary" VARCHAR(254),
    "outbound_proxy_secondary" VARCHAR(254),
    "display_name" VARCHAR(254),
    "user_id" VARCHAR(254),
    "auth_id" VARCHAR(254),
    "password" VARCHAR(254),
    "sip_port" DECIMAL(5,0),
    "sip_transport" VARCHAR(254),
    "register_expires" DECIMAL(5,0),
    "shared_line" VARCHAR(128),
    "enabled" VARCHAR(8) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "device_id" UUID NOT NULL,

    CONSTRAINT "pbx_device_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_device_profile_keys" (
    "id" UUID NOT NULL,
    "category" VARCHAR(16) NOT NULL,
    "key_id" DECIMAL(11,0) NOT NULL,
    "key_type" VARCHAR(64) NOT NULL,
    "line" DECIMAL(3,0) NOT NULL,
    "value" VARCHAR(254),
    "extension" VARCHAR(64),
    "protected" VARCHAR(8) NOT NULL,
    "label" VARCHAR(64),
    "icon" VARCHAR(64),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "profile_id" UUID NOT NULL,

    CONSTRAINT "pbx_device_profile_keys_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_device_profile_settings" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "value" VARCHAR(254),
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "profile_id" UUID NOT NULL,

    CONSTRAINT "pbx_device_profile_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_device_profiles" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_id_id" UUID,
    "vendor_id" UUID,

    CONSTRAINT "pbx_device_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_device_settings" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "value" VARCHAR(254),
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "device_id" UUID NOT NULL,

    CONSTRAINT "pbx_device_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_device_vendor_function_groups" (
    "id" UUID NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "function_id" UUID NOT NULL,
    "group_id" INTEGER NOT NULL,

    CONSTRAINT "pbx_device_vendor_function_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_device_vendor_functions" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "value" VARCHAR(254),
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "vendor_id" UUID NOT NULL,

    CONSTRAINT "pbx_device_vendor_functions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_device_vendors" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,

    CONSTRAINT "pbx_device_vendors_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_devices" (
    "id" UUID NOT NULL,
    "mac_address" VARCHAR(24) NOT NULL,
    "label" VARCHAR(64),
    "model" VARCHAR(64),
    "firmware_version" VARCHAR(64),
    "template" VARCHAR(254),
    "username" VARCHAR(32),
    "password" VARCHAR(32),
    "provisioned_date" TIMESTAMPTZ(6),
    "provisioned_method" VARCHAR(16),
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(254),
    "provisioned_ip" INET,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_id_id" UUID,
    "profile_id_id" UUID,
    "user_id_id" BIGINT,
    "vendor_id" UUID,
    "alternate_id" UUID,

    CONSTRAINT "pbx_devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_dialplan_details" (
    "id" UUID NOT NULL,
    "tag" VARCHAR(32) NOT NULL,
    "type" VARCHAR(128),
    "data" VARCHAR(512),
    "dp_break" VARCHAR(8),
    "inline" VARCHAR(8),
    "group" DECIMAL(11,0) NOT NULL,
    "sequence" DECIMAL(11,0) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "dialplan_id_id" UUID NOT NULL,
    "enabled" VARCHAR(8) NOT NULL,

    CONSTRAINT "pbx_dialplan_details_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_dialplan_excludes" (
    "id" UUID NOT NULL,
    "domain_name" VARCHAR(128) NOT NULL,
    "name" VARCHAR(64),
    "app_id" UUID NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_id_id" UUID,

    CONSTRAINT "pbx_dialplan_excludes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_dialplans" (
    "id" UUID NOT NULL,
    "app_id" UUID,
    "hostname" VARCHAR(128),
    "context" VARCHAR(128),
    "category" VARCHAR(32),
    "name" VARCHAR(64),
    "number" VARCHAR(128),
    "destination" VARCHAR(8) NOT NULL,
    "dp_continue" VARCHAR(8) NOT NULL,
    "xml" TEXT,
    "sequence" DECIMAL(3,0) NOT NULL,
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_id_id" UUID,

    CONSTRAINT "pbx_dialplans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_domain_settings" (
    "id" UUID NOT NULL,
    "app_uuid" UUID,
    "category" VARCHAR(32) NOT NULL,
    "subcategory" VARCHAR(64) NOT NULL,
    "value_type" VARCHAR(32) NOT NULL,
    "value" VARCHAR(254),
    "sequence" DECIMAL(11,0) NOT NULL,
    "disabled" BOOLEAN NOT NULL DEFAULT false,
    "description" VARCHAR(128),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domainId" UUID NOT NULL,

    CONSTRAINT "pbx_domain_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_domains" (
    "id" UUID NOT NULL,
    "name" VARCHAR(128) NOT NULL,
    "disabled" BOOLEAN NOT NULL DEFAULT false,
    "description" VARCHAR(128),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updatedBy" VARCHAR(64) NOT NULL,
    "homeSwitch" VARCHAR(128),
    "menuId" UUID,
    "portalName" VARCHAR(128),

    CONSTRAINT "pbx_domains_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_email_templates" (
    "id" UUID NOT NULL,
    "language" VARCHAR(8) NOT NULL,
    "category" VARCHAR(32) NOT NULL,
    "subcategory" VARCHAR(32) NOT NULL,
    "subject" VARCHAR(128),
    "type" VARCHAR(8) NOT NULL,
    "body" TEXT,
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updatedBy" VARCHAR(64) NOT NULL,
    "domain_id_id" UUID,

    CONSTRAINT "pbx_email_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_extension_users" (
    "id" UUID NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "extension_uuid" UUID,
    "user_uuid" UUID,
    "default_user" VARCHAR(8) NOT NULL,

    CONSTRAINT "pbx_extension_users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_extensions" (
    "id" UUID NOT NULL,
    "extension" VARCHAR(32) NOT NULL,
    "number_alias" VARCHAR(16),
    "password" VARCHAR(32) NOT NULL,
    "accountcode" VARCHAR(32),
    "effective_caller_id_name" VARCHAR(32),
    "effective_caller_id_number" VARCHAR(16),
    "outbound_caller_id_name" VARCHAR(32),
    "outbound_caller_id_number" VARCHAR(16),
    "emergency_caller_id_name" VARCHAR(32),
    "emergency_caller_id_number" VARCHAR(16),
    "directory_first_name" VARCHAR(32),
    "directory_last_name" VARCHAR(32),
    "directory_visible" VARCHAR(8) NOT NULL,
    "directory_exten_visible" VARCHAR(8) NOT NULL,
    "limit_max" DECIMAL(11,0),
    "limit_destination" VARCHAR(32),
    "missed_call_app" VARCHAR(32),
    "missed_call_data" VARCHAR(256),
    "user_context" VARCHAR(128),
    "toll_allow" VARCHAR(32),
    "call_timeout" DECIMAL(11,0),
    "call_group" VARCHAR(32),
    "call_screen_enabled" VARCHAR(8) NOT NULL,
    "user_record" VARCHAR(8),
    "hold_music" VARCHAR(64),
    "auth_acl" VARCHAR(16),
    "cidr" VARCHAR(128),
    "sip_force_contact" VARCHAR(64),
    "nibble_account" DECIMAL(1,0),
    "sip_force_expires" DECIMAL(11,0),
    "mwi_account" VARCHAR(256),
    "sip_bypass_media" VARCHAR(32),
    "unique_id" DECIMAL(1,0),
    "dial_string" TEXT,
    "dial_user" VARCHAR(32),
    "dial_domain" VARCHAR(128),
    "do_not_disturb" VARCHAR(8) NOT NULL,
    "forward_all_destination" VARCHAR(16),
    "forward_all_enabled" VARCHAR(8) NOT NULL,
    "forward_busy_destination" VARCHAR(16),
    "forward_busy_enabled" VARCHAR(8) NOT NULL,
    "forward_no_answer_destination" VARCHAR(16),
    "forward_no_answer_enabled" VARCHAR(8) NOT NULL,
    "forward_user_not_registered_destination" VARCHAR(16),
    "forward_user_not_registered_enabled" VARCHAR(8) NOT NULL,
    "follow_me_uuid" UUID,
    "forward_caller_id" VARCHAR(16),
    "follow_me_enabled" VARCHAR(8) NOT NULL,
    "follow_me_destinations" TEXT,
    "disabled" BOOLEAN NOT NULL DEFAULT false,
    "description" VARCHAR(64),
    "absolute_codec_string" VARCHAR(64),
    "force_ping" VARCHAR(8) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,

    CONSTRAINT "pbx_extensions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_failed_logins" (
    "id" UUID NOT NULL,
    "address" INET NOT NULL,
    "username" VARCHAR(254),
    "attempts" DECIMAL(4,0) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,

    CONSTRAINT "pbx_failed_logins_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_follow_me_destinations" (
    "id" UUID NOT NULL,
    "destination" VARCHAR(32) NOT NULL,
    "delay" DECIMAL(3,0) NOT NULL,
    "timeout" DECIMAL(3,0) NOT NULL,
    "prompt" VARCHAR(8),
    "sequence" DECIMAL(11,0),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "extension_uuid" UUID,

    CONSTRAINT "pbx_follow_me_destinations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_gateways" (
    "id" UUID NOT NULL,
    "gateway" VARCHAR(64) NOT NULL,
    "username" VARCHAR(64),
    "password" VARCHAR(64),
    "distinct_to" VARCHAR(8),
    "auth_username" VARCHAR(64),
    "realm" VARCHAR(128),
    "from_user" VARCHAR(64),
    "from_domain" VARCHAR(128),
    "proxy" VARCHAR(128) NOT NULL,
    "register_proxy" VARCHAR(128),
    "outbound_proxy" VARCHAR(128),
    "expire_seconds" DECIMAL(5,0) NOT NULL,
    "register" VARCHAR(8) NOT NULL,
    "register_transport" VARCHAR(8),
    "retry_seconds" DECIMAL(4,0) NOT NULL,
    "extension" VARCHAR(64),
    "ping" VARCHAR(8),
    "caller_id_in_from" VARCHAR(8),
    "supress_cng" VARCHAR(8),
    "sip_cid_type" VARCHAR(8),
    "codec_prefs" VARCHAR(64),
    "channels" DECIMAL(4,0) NOT NULL,
    "extension_in_contact" VARCHAR(8),
    "context" VARCHAR(128) NOT NULL,
    "profile" VARCHAR(64) NOT NULL,
    "hostname" VARCHAR(128),
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(64),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,

    CONSTRAINT "pbx_gateways_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_httapi_session" (
    "id" UUID NOT NULL,
    "name" VARCHAR(32) NOT NULL,
    "xml" TEXT,
    "json" JSONB,
    "created" TIMESTAMPTZ(6),

    CONSTRAINT "pbx_httapi_session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_ip_register" (
    "id" UUID NOT NULL,
    "address" INET NOT NULL,
    "status" DECIMAL(2,0) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,

    CONSTRAINT "pbx_ip_register_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_ivr_menu_options" (
    "id" UUID NOT NULL,
    "option_digits" VARCHAR(8),
    "option_action" VARCHAR(64),
    "option_param" VARCHAR(128) NOT NULL,
    "sequence" DECIMAL(3,0) NOT NULL,
    "description" VARCHAR(64),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "ivr_menu_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_ivr_menu_options_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_ivr_menus" (
    "id" UUID NOT NULL,
    "dialplan_id" UUID,
    "name" VARCHAR(64),
    "extension" VARCHAR(32) NOT NULL,
    "language" VARCHAR(32),
    "greet_long" VARCHAR(254),
    "greet_short" VARCHAR(254),
    "invalid_sound" VARCHAR(254),
    "exit_sound" VARCHAR(254),
    "confirm_macro" VARCHAR(254),
    "confirm_key" VARCHAR(8),
    "tts_engine" VARCHAR(64),
    "tts_voice" VARCHAR(254),
    "confirm_attempts" DECIMAL(2,0) NOT NULL,
    "timeout" DECIMAL(5,0) NOT NULL,
    "exit_app" VARCHAR(32),
    "exit_data" VARCHAR(256),
    "inter_digit_timeout" DECIMAL(5,0) NOT NULL,
    "max_failiures" DECIMAL(2,0) NOT NULL,
    "max_timeouts" DECIMAL(2,0) NOT NULL,
    "digit_len" DECIMAL(2,0) NOT NULL,
    "direct_dial" VARCHAR(8) NOT NULL,
    "ringback" VARCHAR(128),
    "cid_prefix" VARCHAR(32),
    "context" VARCHAR(128),
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(64),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,

    CONSTRAINT "pbx_ivr_menus_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_menu_item_groups" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "group_id" INTEGER NOT NULL,
    "menu_item_id" UUID NOT NULL,

    CONSTRAINT "pbx_menu_item_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_menu_items" (
    "id" UUID NOT NULL,
    "title" VARCHAR(64) NOT NULL,
    "link" VARCHAR(128),
    "icon" VARCHAR(32),
    "category" VARCHAR(16) NOT NULL,
    "protected" VARCHAR(8) NOT NULL,
    "sequence" DECIMAL(11,0) NOT NULL,
    "description" VARCHAR(128) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "menu_id" UUID NOT NULL,
    "parent_id" UUID,

    CONSTRAINT "pbx_menu_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_menus" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "description" VARCHAR(128) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,

    CONSTRAINT "pbx_menus_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_modules" (
    "id" UUID NOT NULL,
    "label" VARCHAR(64) NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "category" VARCHAR(64) NOT NULL,
    "sequence" DECIMAL(11,0) NOT NULL,
    "enabled" VARCHAR(8) NOT NULL,
    "default_enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,

    CONSTRAINT "pbx_modules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_music_on_hold" (
    "id" UUID NOT NULL,
    "name" VARCHAR(32) NOT NULL,
    "path" VARCHAR(256) NOT NULL,
    "rate" DECIMAL(11,0) NOT NULL,
    "shuffle" VARCHAR(8) NOT NULL,
    "channels" DECIMAL(11,0),
    "interval" DECIMAL(11,0),
    "timer_name" VARCHAR(32) NOT NULL,
    "chime_list" VARCHAR(64),
    "chime_freq" DECIMAL(11,0),
    "chime_max" DECIMAL(11,0),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,

    CONSTRAINT "pbx_music_on_hold_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_music_on_hold_files" (
    "id" UUID NOT NULL,
    "filename" TEXT NOT NULL,
    "file_name" VARCHAR(256) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "moh_id_id" UUID NOT NULL,
    "filestore" VARCHAR(128) NOT NULL,

    CONSTRAINT "pbx_music_on_hold_files_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_number_translation_details" (
    "id" UUID NOT NULL,
    "td_regex" VARCHAR(128),
    "td_replace" VARCHAR(128),
    "td_order" DECIMAL(3,0) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "number_translation_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_number_translation_details_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_number_translations" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64),
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(64),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,

    CONSTRAINT "pbx_number_translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_phrase_details" (
    "id" UUID NOT NULL,
    "pfunction" VARCHAR(16) NOT NULL,
    "data" VARCHAR(254),
    "sequence" DECIMAL(11,0) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "phrase_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_phrase_details_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_phrases" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64),
    "language" VARCHAR(8) NOT NULL,
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(64),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,

    CONSTRAINT "pbx_phrases_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_recordings" (
    "id" UUID NOT NULL,
    "filename" TEXT NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "description" VARCHAR(128),
    "base64" TEXT,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,
    "filestore" VARCHAR(128) NOT NULL,

    CONSTRAINT "pbx_recordings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_ring_group_destinations" (
    "id" UUID NOT NULL,
    "number" VARCHAR(128) NOT NULL,
    "delay" DECIMAL(3,0) NOT NULL,
    "timeout" DECIMAL(3,0) NOT NULL,
    "destination_prompt" DECIMAL(3,0) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "ring_group_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_ring_group_destinations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_ring_group_users" (
    "id" UUID NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "ring_group_id_id" UUID NOT NULL,
    "user_uuid" UUID,

    CONSTRAINT "pbx_ring_group_users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_ring_groups" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64),
    "extension" VARCHAR(32) NOT NULL,
    "greeting" VARCHAR(254),
    "strategy" VARCHAR(16),
    "timeout_app" VARCHAR(32),
    "timeout_data" VARCHAR(256),
    "call_timeout" DECIMAL(3,0) NOT NULL,
    "caller_id_name" VARCHAR(32),
    "caller_id_number" VARCHAR(16),
    "cid_name_prefix" VARCHAR(32),
    "cid_number_prefix" VARCHAR(16),
    "distinctive_ring" VARCHAR(32),
    "ring_group_ringback" VARCHAR(128),
    "follow_me_enabled" VARCHAR(8) NOT NULL,
    "missed_call_app" VARCHAR(32),
    "missed_call_data" VARCHAR(256),
    "forward_enabled" VARCHAR(8) NOT NULL,
    "forward_destination" VARCHAR(128),
    "forward_toll_allow" VARCHAR(32),
    "context" VARCHAR(128),
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(64),
    "dialplan_id" UUID,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_uuid" UUID,

    CONSTRAINT "pbx_ring_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_sip_profile_domains" (
    "id" UUID NOT NULL,
    "name" VARCHAR(128) NOT NULL,
    "alias" VARCHAR(8) NOT NULL,
    "parse" VARCHAR(8) NOT NULL,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "sip_profile_id" UUID NOT NULL,

    CONSTRAINT "pbx_sip_profile_domains_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_sip_profile_settings" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "value" VARCHAR(254),
    "disabled" BOOLEAN NOT NULL,
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "sip_profile_id" UUID NOT NULL,

    CONSTRAINT "pbx_sip_profile_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_sip_profiles" (
    "id" UUID NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "hostname" VARCHAR(128),
    "disabled" BOOLEAN NOT NULL,
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,

    CONSTRAINT "pbx_sip_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_user_settings" (
    "id" UUID NOT NULL,
    "category" VARCHAR(32) NOT NULL,
    "subcategory" VARCHAR(64) NOT NULL,
    "value_type" VARCHAR(32) NOT NULL,
    "value" VARCHAR(254),
    "sequence" DECIMAL(11,0) NOT NULL,
    "disabled" BOOLEAN NOT NULL,
    "description" VARCHAR(128),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "user_id_id" BIGINT NOT NULL,

    CONSTRAINT "pbx_user_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_users" (
    "id" BIGSERIAL NOT NULL,
    "user_uuid" UUID NOT NULL,
    "username" VARCHAR(150) NOT NULL,
    "email" VARCHAR(254),
    "status" VARCHAR(32) NOT NULL,
    "api_key" VARCHAR(254),
    "disabled" BOOLEAN NOT NULL DEFAULT false,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updatedBy" VARCHAR(64) NOT NULL,
    "domainId" UUID,
    "auth_user_id" VARCHAR(50),

    CONSTRAINT "pbx_users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_vars" (
    "id" UUID NOT NULL,
    "category" VARCHAR(64) NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "value" VARCHAR(254),
    "command" VARCHAR(16),
    "hostname" VARCHAR(128),
    "enabled" VARCHAR(8) NOT NULL,
    "sequence" DECIMAL(11,0) NOT NULL,
    "description" TEXT,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,

    CONSTRAINT "pbx_vars_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_voicemail_destinations" (
    "id" UUID NOT NULL,
    "voicemail_dest" UUID,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "voicemail_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_voicemail_destinations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_voicemail_greetings" (
    "id" UUID NOT NULL,
    "filename" TEXT NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "description" VARCHAR(128),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "voicemail_id_id" UUID,
    "filestore" VARCHAR(128) NOT NULL,

    CONSTRAINT "pbx_voicemail_greetings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_voicemail_messages" (
    "id" UUID NOT NULL,
    "filename" TEXT NOT NULL,
    "name" VARCHAR(64) NOT NULL,
    "filestore" VARCHAR(128) NOT NULL,
    "caller_id_name" VARCHAR(32),
    "caller_id_number" VARCHAR(32),
    "duration" DECIMAL(32,0) NOT NULL,
    "status" VARCHAR(64) NOT NULL,
    "read" TIMESTAMPTZ(6),
    "transcription" TEXT,
    "base64" TEXT,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "voicemail_id_id" UUID,

    CONSTRAINT "pbx_voicemail_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_voicemail_options" (
    "id" UUID NOT NULL,
    "option_digits" VARCHAR(8),
    "option_action" VARCHAR(64),
    "option_param" VARCHAR(128) NOT NULL,
    "sequence" DECIMAL(3,0) NOT NULL,
    "description" VARCHAR(64),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "voicemail_id_id" UUID NOT NULL,

    CONSTRAINT "pbx_voicemail_options_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_voicemails" (
    "id" UUID NOT NULL,
    "password" VARCHAR(16),
    "greeting_id" DECIMAL(2,0),
    "alternate_greeting_id" DECIMAL(2,0),
    "mail_to" VARCHAR(256),
    "sms_to" VARCHAR(32),
    "cc" VARCHAR(64),
    "attach_file" VARCHAR(8) NOT NULL,
    "local_after_email" VARCHAR(8) NOT NULL,
    "enabled" VARCHAR(8) NOT NULL,
    "description" VARCHAR(256),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "extension_id_id" UUID,

    CONSTRAINT "pbx_voicemails_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pbx_xml_cdr" (
    "id" UUID NOT NULL,
    "domain_name" VARCHAR(128),
    "accountcode" VARCHAR(32),
    "direction" VARCHAR(16),
    "context" VARCHAR(128),
    "caller_id_name" VARCHAR(32),
    "caller_id_number" VARCHAR(32),
    "caller_destination" VARCHAR(32),
    "source_number" VARCHAR(32),
    "destination_number" VARCHAR(32),
    "start_epoch" DECIMAL(32,0),
    "start_stamp" TIMESTAMPTZ(6),
    "answer_epoch" DECIMAL(32,0),
    "answer_stamp" TIMESTAMPTZ(6),
    "end_epoch" DECIMAL(32,0),
    "end_stamp" TIMESTAMPTZ(6),
    "duration" DECIMAL(32,0),
    "mduration" DECIMAL(32,0),
    "billsec" DECIMAL(32,0),
    "billmsec" DECIMAL(32,0),
    "bridge_uuid" UUID,
    "read_codec" VARCHAR(16),
    "read_rate" VARCHAR(16),
    "write_codec" VARCHAR(16),
    "write_rate" VARCHAR(16),
    "remote_media_ip" VARCHAR(128),
    "network_addr" VARCHAR(128),
    "record_path" VARCHAR(256),
    "record_name" VARCHAR(64),
    "leg" VARCHAR(8),
    "pdd_ms" DECIMAL(32,0),
    "rtp_audio_in_mos" DECIMAL(4,2),
    "last_app" VARCHAR(32),
    "last_arg" TEXT,
    "missed_call" BOOLEAN,
    "cc_side" VARCHAR(16),
    "cc_member_uuid" UUID,
    "cc_queue_joined_epoch" DECIMAL(32,0),
    "cc_queue" UUID,
    "cc_member_session_uuid" UUID,
    "cc_agent_uuid" UUID,
    "cc_agent" UUID,
    "cc_agent_type" VARCHAR(32),
    "cc_agent_bridged" VARCHAR(8),
    "cc_queue_answered_epoch" DECIMAL(32,0),
    "cc_queue_terminated_epoch" DECIMAL(32,0),
    "cc_queue_canceled_epoch" DECIMAL(32,0),
    "cc_cancel_reason" VARCHAR(32),
    "cc_cause" VARCHAR(32),
    "waitsec" DECIMAL(32,0),
    "conference_name" VARCHAR(256),
    "conference_uuid" UUID,
    "conference_member_id" VARCHAR(8),
    "digits_dialed" VARCHAR(64),
    "pin_number" VARCHAR(16),
    "hangup_cause" VARCHAR(32),
    "hangup_cause_q850" DECIMAL(4,0),
    "sip_hangup_disposition" VARCHAR(32),
    "xml" TEXT,
    "json" JSONB,
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,
    "domain_id_id" UUID,
    "extension_id_id" UUID,
    "core_uuid" UUID,
    "call_uuid" UUID,

    CONSTRAINT "pbx_xml_cdr_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "auth_group_name_key" ON "auth_group"("name");

-- CreateIndex
CREATE INDEX "auth_group_name_idx" ON "auth_group"("name");

-- CreateIndex
CREATE UNIQUE INDEX "auth_permission_codename_unique" ON "auth_permission"("codename");

-- CreateIndex
CREATE INDEX "auth_group_permissions_groupId_idx" ON "auth_group_permissions"("groupId");

-- CreateIndex
CREATE INDEX "auth_group_permissions_permissionId_idx" ON "auth_group_permissions"("permissionId");

-- CreateIndex
CREATE UNIQUE INDEX "auth_group_permissions_groupId_permissionId_key" ON "auth_group_permissions"("groupId", "permissionId");

-- CreateIndex
CREATE UNIQUE INDEX "auth_tenant_name_key" ON "auth_tenant"("name");

-- CreateIndex
CREATE UNIQUE INDEX "auth_tenant_firebaseTenantId_key" ON "auth_tenant"("firebaseTenantId");

-- CreateIndex
CREATE UNIQUE INDEX "auth_user_uid_key" ON "auth_user"("uid");

-- CreateIndex
CREATE UNIQUE INDEX "auth_user_email_key" ON "auth_user"("email");

-- CreateIndex
CREATE INDEX "auth_user_tenantId_idx" ON "auth_user"("tenantId");

-- CreateIndex
CREATE INDEX "auth_user_email_idx" ON "auth_user"("email");

-- CreateIndex
CREATE UNIQUE INDEX "invite_token_key" ON "invite"("token");

-- CreateIndex
CREATE INDEX "invite_email_idx" ON "invite"("email");

-- CreateIndex
CREATE INDEX "invite_token_idx" ON "invite"("token");

-- CreateIndex
CREATE INDEX "invite_domainId_idx" ON "invite"("domainId");

-- CreateIndex
CREATE INDEX "invite_groupId_idx" ON "invite"("groupId");

-- CreateIndex
CREATE UNIQUE INDEX "subscription_domainId_key" ON "subscription"("domainId");

-- CreateIndex
CREATE UNIQUE INDEX "subscription_slug_key" ON "subscription"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "subscription_stripeCustomerId_key" ON "subscription"("stripeCustomerId");

-- CreateIndex
CREATE UNIQUE INDEX "subscription_stripeSubscriptionId_key" ON "subscription"("stripeSubscriptionId");

-- CreateIndex
CREATE INDEX "subscription_slug_idx" ON "subscription"("slug");

-- CreateIndex
CREATE INDEX "subscription_status_idx" ON "subscription"("status");

-- CreateIndex
CREATE INDEX "subscription_stripeCustomerId_idx" ON "subscription"("stripeCustomerId");

-- CreateIndex
CREATE INDEX "auth_user_groups_groupId_idx" ON "auth_user_groups"("groupId");

-- CreateIndex
CREATE INDEX "auth_user_groups_uid_idx" ON "auth_user_groups"("uid");

-- CreateIndex
CREATE UNIQUE INDEX "auth_user_groups_uid_groupId_key" ON "auth_user_groups"("uid", "groupId");

-- CreateIndex
CREATE INDEX "auth_user_user_permissions_permissionId_idx" ON "auth_user_user_permissions"("permissionId");

-- CreateIndex
CREATE INDEX "auth_user_user_permissions_uid_idx" ON "auth_user_user_permissions"("uid");

-- CreateIndex
CREATE UNIQUE INDEX "auth_user_user_permissions_uid_permissionId_key" ON "auth_user_user_permissions"("uid", "permissionId");

-- CreateIndex
CREATE UNIQUE INDEX "authtoken_token_uid_key" ON "authtoken_token"("uid");

-- CreateIndex
CREATE INDEX "authtoken_token_key_idx" ON "authtoken_token"("key");

-- CreateIndex
CREATE INDEX "pbx_access_control_nodes_access_control_id_id_d842e92a" ON "pbx_access_control_nodes"("access_control_id_id");

-- CreateIndex
CREATE INDEX "pbx_auto_report_domain_uuid_80816be5" ON "pbx_auto_report"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_auto_report_section_auto_report_id_ca93bf77" ON "pbx_auto_report_section"("auto_report_id");

-- CreateIndex
CREATE INDEX "pbx_bridges_domain_uuid_41623292" ON "pbx_bridges"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_call_block_domain_uuid_6e47cf15" ON "pbx_call_block"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_call_centre_agents_domain_uuid_e3542885" ON "pbx_call_centre_agents"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_call_centre_agents_user_uuid_6eab1ecb" ON "pbx_call_centre_agents"("user_uuid");

-- CreateIndex
CREATE UNIQUE INDEX "pbx_call_centre_agents_domain_uuid_agent_id_cfab14bd_uniq" ON "pbx_call_centre_agents"("domain_uuid", "agent_id");

-- CreateIndex
CREATE INDEX "pbx_call_centre_queues_domain_uuid_496e4188" ON "pbx_call_centre_queues"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_call_centre_tiers_agent_id_id_bbc2132e" ON "pbx_call_centre_tiers"("agent_id_id");

-- CreateIndex
CREATE INDEX "pbx_call_centre_tiers_queue_id_id_24aa23a1" ON "pbx_call_centre_tiers"("queue_id_id");

-- CreateIndex
CREATE INDEX "pbx_call_flows_context_1e7d42c9" ON "pbx_call_flows"("context");

-- CreateIndex
CREATE INDEX "pbx_call_flows_context_1e7d42c9_like" ON "pbx_call_flows"("context");

-- CreateIndex
CREATE INDEX "pbx_call_flows_domain_uuid_436e3fcb" ON "pbx_call_flows"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_call_recordings_domain_uuid_3687ddea" ON "pbx_call_recordings"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_call_timeline_call_uuid_72a645a2" ON "pbx_call_timeline"("call_uuid");

-- CreateIndex
CREATE INDEX "pbx_call_timeline_caller_destination_b490e043" ON "pbx_call_timeline"("caller_destination");

-- CreateIndex
CREATE INDEX "pbx_call_timeline_caller_destination_b490e043_like" ON "pbx_call_timeline"("caller_destination");

-- CreateIndex
CREATE INDEX "pbx_call_timeline_caller_id_number_4af58329" ON "pbx_call_timeline"("caller_id_number");

-- CreateIndex
CREATE INDEX "pbx_call_timeline_caller_id_number_4af58329_like" ON "pbx_call_timeline"("caller_id_number");

-- CreateIndex
CREATE INDEX "pbx_call_timeline_context_1954e0b5" ON "pbx_call_timeline"("context");

-- CreateIndex
CREATE INDEX "pbx_call_timeline_context_1954e0b5_like" ON "pbx_call_timeline"("context");

-- CreateIndex
CREATE INDEX "pbx_call_timeline_core_uuid_93da4e16" ON "pbx_call_timeline"("core_uuid");

-- CreateIndex
CREATE INDEX "pbx_call_timeline_domain_id_id_5b2e0564" ON "pbx_call_timeline"("domain_id_id");

-- CreateIndex
CREATE INDEX "pbx_call_timeline_event_epoch_487ada5d" ON "pbx_call_timeline"("event_epoch");

-- CreateIndex
CREATE INDEX "pbx_call_timeline_other_leg_unique_id_e3fa69df" ON "pbx_call_timeline"("other_leg_unique_id");

-- CreateIndex
CREATE INDEX "pbx_call_timeline_unique_id_f9a14337" ON "pbx_call_timeline"("unique_id");

-- CreateIndex
CREATE INDEX "pbx_cc_agent_status_log_agent_id_id_2fe7e484" ON "pbx_cc_agent_status_log"("agent_id_id");

-- CreateIndex
CREATE INDEX "pbx_conference_centres_domain_uuid_734e0ffb" ON "pbx_conference_centres"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_conference_control_details_conf_ctrl_id_id_487dc607" ON "pbx_conference_control_details"("conf_ctrl_id_id");

-- CreateIndex
CREATE INDEX "pbx_conference_profile_params_conf_profile_id_id_4829dcec" ON "pbx_conference_profile_params"("conf_profile_id_id");

-- CreateIndex
CREATE INDEX "pbx_conference_room_users_c_room_id_id_b06cc2c1" ON "pbx_conference_room_users"("c_room_id_id");

-- CreateIndex
CREATE INDEX "pbx_conference_room_users_user_uuid_f8ec5578" ON "pbx_conference_room_users"("user_uuid");

-- CreateIndex
CREATE INDEX "pbx_conference_rooms_c_centre_id_id_b917996a" ON "pbx_conference_rooms"("c_centre_id_id");

-- CreateIndex
CREATE INDEX "pbx_conference_rooms_c_profile_id_id_14ed4f86" ON "pbx_conference_rooms"("c_profile_id_id");

-- CreateIndex
CREATE UNIQUE INDEX "pbx_conference_rooms_c_centre_id_id_moderator_pin_b138db4e_uniq" ON "pbx_conference_rooms"("c_centre_id_id", "moderator_pin");

-- CreateIndex
CREATE UNIQUE INDEX "pbx_conference_rooms_c_centre_id_id_participa_c8fb4ea1_uniq" ON "pbx_conference_rooms"("c_centre_id_id", "participant_pin");

-- CreateIndex
CREATE INDEX "pbx_conference_sessions_c_room_id_id_f5c1cfb4" ON "pbx_conference_sessions"("c_room_id_id");

-- CreateIndex
CREATE INDEX "pbx_contacts_domain_id_id_5e67d2a4" ON "pbx_contacts"("domain_id_id");

-- CreateIndex
CREATE INDEX "pbx_contacts_user_id_id_0ad8c3a4" ON "pbx_contacts"("user_id_id");

-- CreateIndex
CREATE INDEX "pbx_contacts_address_contact_id_id_efcbd0bb" ON "pbx_contacts_address"("contact_id_id");

-- CreateIndex
CREATE INDEX "pbx_contacts_category_contact_id_id_490708cf" ON "pbx_contacts_category"("contact_id_id");

-- CreateIndex
CREATE INDEX "pbx_contacts_dates_contact_id_id_954dc217" ON "pbx_contacts_dates"("contact_id_id");

-- CreateIndex
CREATE INDEX "pbx_contacts_email_contact_id_id_a3fd5069" ON "pbx_contacts_email"("contact_id_id");

-- CreateIndex
CREATE INDEX "pbx_contacts_geo_contact_id_id_cbb59f6e" ON "pbx_contacts_geo"("contact_id_id");

-- CreateIndex
CREATE INDEX "pbx_contacts_groups_contact_id_id_83fcf911" ON "pbx_contacts_groups"("contact_id_id");

-- CreateIndex
CREATE INDEX "pbx_contacts_groups_group_id_dc0329a4" ON "pbx_contacts_groups"("group_id");

-- CreateIndex
CREATE INDEX "pbx_contacts_org_contact_id_id_d5127702" ON "pbx_contacts_org"("contact_id_id");

-- CreateIndex
CREATE INDEX "pbx_contacts_tel_contact_id_id_3ac83646" ON "pbx_contacts_tel"("contact_id_id");

-- CreateIndex
CREATE INDEX "pbx_contacts_url_contact_id_id_3a99de63" ON "pbx_contacts_url"("contact_id_id");

-- CreateIndex
CREATE INDEX "pbx_default_settings_category_0b9f954d" ON "pbx_default_settings"("category");

-- CreateIndex
CREATE INDEX "pbx_default_settings_category_0b9f954d_like" ON "pbx_default_settings"("category");

-- CreateIndex
CREATE INDEX "pbx_default_settings_subcategory_5e12c14d" ON "pbx_default_settings"("subcategory");

-- CreateIndex
CREATE INDEX "pbx_default_settings_subcategory_5e12c14d_like" ON "pbx_default_settings"("subcategory");

-- CreateIndex
CREATE INDEX "pbx_default_settings_value_type_0fa61d41" ON "pbx_default_settings"("value_type");

-- CreateIndex
CREATE INDEX "pbx_default_settings_value_type_0fa61d41_like" ON "pbx_default_settings"("value_type");

-- CreateIndex
CREATE INDEX "pbx_device_keys_device_id_3e0c21ec" ON "pbx_device_keys"("device_id");

-- CreateIndex
CREATE INDEX "pbx_device_lines_device_id_b3ca7db8" ON "pbx_device_lines"("device_id");

-- CreateIndex
CREATE INDEX "pbx_device_profile_keys_profile_id_5c98872a" ON "pbx_device_profile_keys"("profile_id");

-- CreateIndex
CREATE INDEX "pbx_device_profile_settings_profile_id_241770f9" ON "pbx_device_profile_settings"("profile_id");

-- CreateIndex
CREATE INDEX "pbx_device_profiles_domain_id_id_4067cb40" ON "pbx_device_profiles"("domain_id_id");

-- CreateIndex
CREATE INDEX "pbx_device_profiles_vendor_id_95ae1fd9" ON "pbx_device_profiles"("vendor_id");

-- CreateIndex
CREATE INDEX "pbx_device_settings_device_id_12903bad" ON "pbx_device_settings"("device_id");

-- CreateIndex
CREATE INDEX "pbx_device_vendor_function_groups_function_id_ea1e5a9b" ON "pbx_device_vendor_function_groups"("function_id");

-- CreateIndex
CREATE INDEX "pbx_device_vendor_function_groups_group_id_67a203de" ON "pbx_device_vendor_function_groups"("group_id");

-- CreateIndex
CREATE INDEX "pbx_device_vendor_functions_vendor_id_949d5c05" ON "pbx_device_vendor_functions"("vendor_id");

-- CreateIndex
CREATE INDEX "pbx_devices_domain_id_id_10d0954a" ON "pbx_devices"("domain_id_id");

-- CreateIndex
CREATE INDEX "pbx_devices_profile_id_id_d05f3c63" ON "pbx_devices"("profile_id_id");

-- CreateIndex
CREATE INDEX "pbx_devices_user_id_id_bd7443ea" ON "pbx_devices"("user_id_id");

-- CreateIndex
CREATE INDEX "pbx_devices_vendor_id_63e85b1c" ON "pbx_devices"("vendor_id");

-- CreateIndex
CREATE INDEX "pbx_dialplan_details_dialplan_id_id_eb4dbc17" ON "pbx_dialplan_details"("dialplan_id_id");

-- CreateIndex
CREATE INDEX "pbx_dialplan_excludes_domain_id_id_4ad02574" ON "pbx_dialplan_excludes"("domain_id_id");

-- CreateIndex
CREATE INDEX "pbx_dialplan_excludes_domain_name_06789052" ON "pbx_dialplan_excludes"("domain_name");

-- CreateIndex
CREATE INDEX "pbx_dialplan_excludes_domain_name_06789052_like" ON "pbx_dialplan_excludes"("domain_name");

-- CreateIndex
CREATE INDEX "pbx_dialplans_category_62ff80d9" ON "pbx_dialplans"("category");

-- CreateIndex
CREATE INDEX "pbx_dialplans_category_62ff80d9_like" ON "pbx_dialplans"("category");

-- CreateIndex
CREATE INDEX "pbx_dialplans_context_9f65b37d" ON "pbx_dialplans"("context");

-- CreateIndex
CREATE INDEX "pbx_dialplans_context_9f65b37d_like" ON "pbx_dialplans"("context");

-- CreateIndex
CREATE INDEX "pbx_dialplans_destination_bb1c9803" ON "pbx_dialplans"("destination");

-- CreateIndex
CREATE INDEX "pbx_dialplans_destination_bb1c9803_like" ON "pbx_dialplans"("destination");

-- CreateIndex
CREATE INDEX "pbx_dialplans_domain_id_id_581e14be" ON "pbx_dialplans"("domain_id_id");

-- CreateIndex
CREATE INDEX "pbx_dialplans_hostname_0e8300e2" ON "pbx_dialplans"("hostname");

-- CreateIndex
CREATE INDEX "pbx_dialplans_hostname_0e8300e2_like" ON "pbx_dialplans"("hostname");

-- CreateIndex
CREATE INDEX "pbx_domain_settings_category_b8b72e31" ON "pbx_domain_settings"("category");

-- CreateIndex
CREATE INDEX "pbx_domain_settings_category_b8b72e31_like" ON "pbx_domain_settings"("category");

-- CreateIndex
CREATE INDEX "pbx_domain_settings_domainId_idx" ON "pbx_domain_settings"("domainId");

-- CreateIndex
CREATE INDEX "pbx_domain_settings_subcategory_db5affbb" ON "pbx_domain_settings"("subcategory");

-- CreateIndex
CREATE INDEX "pbx_domain_settings_subcategory_db5affbb_like" ON "pbx_domain_settings"("subcategory");

-- CreateIndex
CREATE INDEX "pbx_domain_settings_value_type_41f42703" ON "pbx_domain_settings"("value_type");

-- CreateIndex
CREATE INDEX "pbx_domain_settings_value_type_41f42703_like" ON "pbx_domain_settings"("value_type");

-- CreateIndex
CREATE UNIQUE INDEX "pbx_domains_name_key" ON "pbx_domains"("name");

-- CreateIndex
CREATE UNIQUE INDEX "pbx_domains_portalName_key" ON "pbx_domains"("portalName");

-- CreateIndex
CREATE INDEX "pbx_domains_menuId_idx" ON "pbx_domains"("menuId");

-- CreateIndex
CREATE INDEX "pbx_domains_name_idx" ON "pbx_domains"("name");

-- CreateIndex
CREATE INDEX "pbx_domains_portalName_idx" ON "pbx_domains"("portalName");

-- CreateIndex
CREATE INDEX "pbx_email_templates_domain_id_id_592ee910" ON "pbx_email_templates"("domain_id_id");

-- CreateIndex
CREATE INDEX "pbx_extension_users_extension_uuid_68cf4da0" ON "pbx_extension_users"("extension_uuid");

-- CreateIndex
CREATE INDEX "pbx_extension_users_user_uuid_c416d33e" ON "pbx_extension_users"("user_uuid");

-- CreateIndex
CREATE INDEX "pbx_extensions_domain_uuid_246c1b36" ON "pbx_extensions"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_extensions_extension_8d76e869" ON "pbx_extensions"("extension");

-- CreateIndex
CREATE INDEX "pbx_extensions_extension_8d76e869_like" ON "pbx_extensions"("extension");

-- CreateIndex
CREATE INDEX "pbx_extensions_number_alias_9f983a90" ON "pbx_extensions"("number_alias");

-- CreateIndex
CREATE INDEX "pbx_extensions_number_alias_9f983a90_like" ON "pbx_extensions"("number_alias");

-- CreateIndex
CREATE UNIQUE INDEX "pbx_extensions_domain_uuid_extension_8ef2eb2b_uniq" ON "pbx_extensions"("domain_uuid", "extension");

-- CreateIndex
CREATE UNIQUE INDEX "pbx_extensions_domain_uuid_number_alias_64dbcbb9_uniq" ON "pbx_extensions"("domain_uuid", "number_alias");

-- CreateIndex
CREATE UNIQUE INDEX "pbx_failed_logins_address_key" ON "pbx_failed_logins"("address");

-- CreateIndex
CREATE INDEX "pbx_follow_me_destinations_extension_uuid_7a65cb1a" ON "pbx_follow_me_destinations"("extension_uuid");

-- CreateIndex
CREATE INDEX "pbx_gateways_domain_uuid_08cbf6c7" ON "pbx_gateways"("domain_uuid");

-- CreateIndex
CREATE UNIQUE INDEX "pbx_ip_register_address_key" ON "pbx_ip_register"("address");

-- CreateIndex
CREATE INDEX "pbx_ivr_menu_options_ivr_menu_id_id_596a92af" ON "pbx_ivr_menu_options"("ivr_menu_id_id");

-- CreateIndex
CREATE INDEX "pbx_ivr_menus_context_23574173" ON "pbx_ivr_menus"("context");

-- CreateIndex
CREATE INDEX "pbx_ivr_menus_context_23574173_like" ON "pbx_ivr_menus"("context");

-- CreateIndex
CREATE INDEX "pbx_ivr_menus_domain_uuid_82c2bc95" ON "pbx_ivr_menus"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_menu_item_groups_group_id_727cd142" ON "pbx_menu_item_groups"("group_id");

-- CreateIndex
CREATE INDEX "pbx_menu_item_groups_menu_item_id_c543d3d6" ON "pbx_menu_item_groups"("menu_item_id");

-- CreateIndex
CREATE INDEX "pbx_menu_items_menu_id_a8e4817b" ON "pbx_menu_items"("menu_id");

-- CreateIndex
CREATE INDEX "pbx_menu_items_parent_id_c68849bb" ON "pbx_menu_items"("parent_id");

-- CreateIndex
CREATE INDEX "pbx_music_on_hold_domain_uuid_f5d415b6" ON "pbx_music_on_hold"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_music_on_hold_files_moh_id_id_2ed7958f" ON "pbx_music_on_hold_files"("moh_id_id");

-- CreateIndex
CREATE INDEX "pbx_number_translation_det_number_translation_id_id_c92ec084" ON "pbx_number_translation_details"("number_translation_id_id");

-- CreateIndex
CREATE INDEX "pbx_phrase_details_phrase_id_id_b0a5c23d" ON "pbx_phrase_details"("phrase_id_id");

-- CreateIndex
CREATE INDEX "pbx_phrases_domain_uuid_3e4927b6" ON "pbx_phrases"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_recordings_domain_uuid_e92a4731" ON "pbx_recordings"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_ring_group_destinations_ring_group_id_id_b1dd9e79" ON "pbx_ring_group_destinations"("ring_group_id_id");

-- CreateIndex
CREATE INDEX "pbx_ring_group_users_ring_group_id_id_f248dec4" ON "pbx_ring_group_users"("ring_group_id_id");

-- CreateIndex
CREATE INDEX "pbx_ring_group_users_user_uuid_78082a94" ON "pbx_ring_group_users"("user_uuid");

-- CreateIndex
CREATE INDEX "pbx_ring_groups_context_378e5e39" ON "pbx_ring_groups"("context");

-- CreateIndex
CREATE INDEX "pbx_ring_groups_context_378e5e39_like" ON "pbx_ring_groups"("context");

-- CreateIndex
CREATE INDEX "pbx_ring_groups_domain_uuid_8ee40c93" ON "pbx_ring_groups"("domain_uuid");

-- CreateIndex
CREATE INDEX "pbx_sip_profile_domains_sip_profile_id_6a5cdae5" ON "pbx_sip_profile_domains"("sip_profile_id");

-- CreateIndex
CREATE INDEX "pbx_sip_profile_settings_sip_profile_id_3d874090" ON "pbx_sip_profile_settings"("sip_profile_id");

-- CreateIndex
CREATE INDEX "pbx_user_settings_category_idx" ON "pbx_user_settings"("category");

-- CreateIndex
CREATE INDEX "pbx_user_settings_subcategory_idx" ON "pbx_user_settings"("subcategory");

-- CreateIndex
CREATE INDEX "pbx_user_settings_user_id_id_idx" ON "pbx_user_settings"("user_id_id");

-- CreateIndex
CREATE INDEX "pbx_user_settings_value_type_idx" ON "pbx_user_settings"("value_type");

-- CreateIndex
CREATE UNIQUE INDEX "pbx_users_user_uuid_key" ON "pbx_users"("user_uuid");

-- CreateIndex
CREATE UNIQUE INDEX "pbx_users_username_key" ON "pbx_users"("username");

-- CreateIndex
CREATE INDEX "pbx_users_domainId_idx" ON "pbx_users"("domainId");

-- CreateIndex
CREATE INDEX "pbx_users_username_idx" ON "pbx_users"("username");

-- CreateIndex
CREATE INDEX "pbx_users_auth_user_id_idx" ON "pbx_users"("auth_user_id");

-- CreateIndex
CREATE INDEX "pbx_voicemail_destinations_voicemail_id_id_31053e0d" ON "pbx_voicemail_destinations"("voicemail_id_id");

-- CreateIndex
CREATE INDEX "pbx_voicemail_greetings_voicemail_id_id_ee67c381" ON "pbx_voicemail_greetings"("voicemail_id_id");

-- CreateIndex
CREATE INDEX "pbx_voicemail_messages_voicemail_id_id_1f5e00d2" ON "pbx_voicemail_messages"("voicemail_id_id");

-- CreateIndex
CREATE INDEX "pbx_voicemail_options_voicemail_id_id_91c19fd9" ON "pbx_voicemail_options"("voicemail_id_id");

-- CreateIndex
CREATE INDEX "pbx_voicemails_extension_id_id_f5c8e5c1" ON "pbx_voicemails"("extension_id_id");

-- CreateIndex
CREATE INDEX "pbx_xml_cdr_domain_id_id_ccce6e81" ON "pbx_xml_cdr"("domain_id_id");

-- CreateIndex
CREATE INDEX "pbx_xml_cdr_extension_id_id_f5f7d64e" ON "pbx_xml_cdr"("extension_id_id");

-- AddForeignKey
ALTER TABLE "auth_group_permissions" ADD CONSTRAINT "auth_group_permissions_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "auth_permission"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "auth_group_permissions" ADD CONSTRAINT "auth_group_permissions_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "auth_group"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "auth_user" ADD CONSTRAINT "auth_user_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "auth_tenant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invite" ADD CONSTRAINT "invite_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "pbx_domains"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invite" ADD CONSTRAINT "invite_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "auth_group"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "subscription" ADD CONSTRAINT "subscription_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "pbx_domains"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth_user_groups" ADD CONSTRAINT "auth_user_groups_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "auth_group"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "auth_user_groups" ADD CONSTRAINT "auth_user_groups_uid_fkey" FOREIGN KEY ("uid") REFERENCES "auth_user"("uid") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "auth_user_user_permissions" ADD CONSTRAINT "auth_user_user_permissions_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "auth_permission"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "auth_user_user_permissions" ADD CONSTRAINT "auth_user_user_permissions_uid_fkey" FOREIGN KEY ("uid") REFERENCES "auth_user"("uid") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "authtoken_token" ADD CONSTRAINT "authtoken_token_uid_fkey" FOREIGN KEY ("uid") REFERENCES "auth_user"("uid") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_access_control_nodes" ADD CONSTRAINT "pbx_access_control_n_access_control_id_id_d842e92a_fk_pbx_acces" FOREIGN KEY ("access_control_id_id") REFERENCES "pbx_access_controls"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_auto_report" ADD CONSTRAINT "pbx_auto_report_domain_uuid_80816be5_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_auto_report_section" ADD CONSTRAINT "pbx_auto_report_sect_auto_report_id_ca93bf77_fk_pbx_auto_" FOREIGN KEY ("auto_report_id") REFERENCES "pbx_auto_report"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_bridges" ADD CONSTRAINT "pbx_bridges_domain_uuid_41623292_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_call_block" ADD CONSTRAINT "pbx_call_block_domain_uuid_6e47cf15_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_call_centre_agents" ADD CONSTRAINT "pbx_call_centre_agen_user_uuid_6eab1ecb_fk_pbx_users" FOREIGN KEY ("user_uuid") REFERENCES "pbx_users"("user_uuid") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_call_centre_agents" ADD CONSTRAINT "pbx_call_centre_agents_domain_uuid_e3542885_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_call_centre_queues" ADD CONSTRAINT "pbx_call_centre_queues_domain_uuid_496e4188_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_call_centre_tiers" ADD CONSTRAINT "pbx_call_centre_tier_agent_id_id_bbc2132e_fk_pbx_call_" FOREIGN KEY ("agent_id_id") REFERENCES "pbx_call_centre_agents"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_call_centre_tiers" ADD CONSTRAINT "pbx_call_centre_tier_queue_id_id_24aa23a1_fk_pbx_call_" FOREIGN KEY ("queue_id_id") REFERENCES "pbx_call_centre_queues"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_call_flows" ADD CONSTRAINT "pbx_call_flows_domain_uuid_436e3fcb_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_call_recordings" ADD CONSTRAINT "pbx_call_recordings_domain_uuid_3687ddea_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_call_timeline" ADD CONSTRAINT "pbx_call_timeline_domain_id_id_5b2e0564_fk_pbx_domains_id" FOREIGN KEY ("domain_id_id") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_cc_agent_status_log" ADD CONSTRAINT "pbx_cc_agent_status__agent_id_id_2fe7e484_fk_pbx_call_" FOREIGN KEY ("agent_id_id") REFERENCES "pbx_call_centre_agents"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_conference_centres" ADD CONSTRAINT "pbx_conference_centres_domain_uuid_734e0ffb_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_conference_control_details" ADD CONSTRAINT "pbx_conference_contr_conf_ctrl_id_id_487dc607_fk_pbx_confe" FOREIGN KEY ("conf_ctrl_id_id") REFERENCES "pbx_conference_controls"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_conference_profile_params" ADD CONSTRAINT "pbx_conference_profi_conf_profile_id_id_4829dcec_fk_pbx_confe" FOREIGN KEY ("conf_profile_id_id") REFERENCES "pbx_conference_profiles"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_conference_room_users" ADD CONSTRAINT "pbx_conference_room__c_room_id_id_b06cc2c1_fk_pbx_confe" FOREIGN KEY ("c_room_id_id") REFERENCES "pbx_conference_rooms"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_conference_room_users" ADD CONSTRAINT "pbx_conference_room__user_uuid_f8ec5578_fk_pbx_users" FOREIGN KEY ("user_uuid") REFERENCES "pbx_users"("user_uuid") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_conference_rooms" ADD CONSTRAINT "pbx_conference_rooms_c_centre_id_id_b917996a_fk_pbx_confe" FOREIGN KEY ("c_centre_id_id") REFERENCES "pbx_conference_centres"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_conference_rooms" ADD CONSTRAINT "pbx_conference_rooms_c_profile_id_id_14ed4f86_fk_pbx_confe" FOREIGN KEY ("c_profile_id_id") REFERENCES "pbx_conference_profiles"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_conference_sessions" ADD CONSTRAINT "pbx_conference_sessi_c_room_id_id_f5c1cfb4_fk_pbx_confe" FOREIGN KEY ("c_room_id_id") REFERENCES "pbx_conference_rooms"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_contacts" ADD CONSTRAINT "pbx_contacts_domain_id_id_5e67d2a4_fk_pbx_domains_id" FOREIGN KEY ("domain_id_id") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_contacts" ADD CONSTRAINT "pbx_contacts_user_id_id_0ad8c3a4_fk_pbx_users_id" FOREIGN KEY ("user_id_id") REFERENCES "pbx_users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_contacts_address" ADD CONSTRAINT "pbx_contacts_address_contact_id_id_efcbd0bb_fk_pbx_contacts_id" FOREIGN KEY ("contact_id_id") REFERENCES "pbx_contacts"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_contacts_category" ADD CONSTRAINT "pbx_contacts_category_contact_id_id_490708cf_fk_pbx_contacts_id" FOREIGN KEY ("contact_id_id") REFERENCES "pbx_contacts"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_contacts_dates" ADD CONSTRAINT "pbx_contacts_dates_contact_id_id_954dc217_fk_pbx_contacts_id" FOREIGN KEY ("contact_id_id") REFERENCES "pbx_contacts"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_contacts_email" ADD CONSTRAINT "pbx_contacts_email_contact_id_id_a3fd5069_fk_pbx_contacts_id" FOREIGN KEY ("contact_id_id") REFERENCES "pbx_contacts"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_contacts_geo" ADD CONSTRAINT "pbx_contacts_geo_contact_id_id_cbb59f6e_fk_pbx_contacts_id" FOREIGN KEY ("contact_id_id") REFERENCES "pbx_contacts"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_contacts_groups" ADD CONSTRAINT "pbx_contacts_groups_contact_id_id_83fcf911_fk_pbx_contacts_id" FOREIGN KEY ("contact_id_id") REFERENCES "pbx_contacts"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_contacts_groups" ADD CONSTRAINT "pbx_contacts_groups_group_id_dc0329a4_fk_auth_group_id" FOREIGN KEY ("group_id") REFERENCES "auth_group"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_contacts_org" ADD CONSTRAINT "pbx_contacts_org_contact_id_id_d5127702_fk_pbx_contacts_id" FOREIGN KEY ("contact_id_id") REFERENCES "pbx_contacts"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_contacts_tel" ADD CONSTRAINT "pbx_contacts_tel_contact_id_id_3ac83646_fk_pbx_contacts_id" FOREIGN KEY ("contact_id_id") REFERENCES "pbx_contacts"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_contacts_url" ADD CONSTRAINT "pbx_contacts_url_contact_id_id_3a99de63_fk_pbx_contacts_id" FOREIGN KEY ("contact_id_id") REFERENCES "pbx_contacts"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_device_keys" ADD CONSTRAINT "pbx_device_keys_device_id_3e0c21ec_fk_pbx_devices_id" FOREIGN KEY ("device_id") REFERENCES "pbx_devices"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_device_lines" ADD CONSTRAINT "pbx_device_lines_device_id_b3ca7db8_fk_pbx_devices_id" FOREIGN KEY ("device_id") REFERENCES "pbx_devices"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_device_profile_keys" ADD CONSTRAINT "pbx_device_profile_k_profile_id_5c98872a_fk_pbx_devic" FOREIGN KEY ("profile_id") REFERENCES "pbx_device_profiles"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_device_profile_settings" ADD CONSTRAINT "pbx_device_profile_s_profile_id_241770f9_fk_pbx_devic" FOREIGN KEY ("profile_id") REFERENCES "pbx_device_profiles"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_device_profiles" ADD CONSTRAINT "pbx_device_profiles_domain_id_id_4067cb40_fk_pbx_domains_id" FOREIGN KEY ("domain_id_id") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_device_profiles" ADD CONSTRAINT "pbx_device_profiles_vendor_id_95ae1fd9_fk_pbx_device_vendors_id" FOREIGN KEY ("vendor_id") REFERENCES "pbx_device_vendors"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_device_settings" ADD CONSTRAINT "pbx_device_settings_device_id_12903bad_fk_pbx_devices_id" FOREIGN KEY ("device_id") REFERENCES "pbx_devices"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_device_vendor_function_groups" ADD CONSTRAINT "pbx_device_vendor_fu_function_id_ea1e5a9b_fk_pbx_devic" FOREIGN KEY ("function_id") REFERENCES "pbx_device_vendor_functions"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_device_vendor_function_groups" ADD CONSTRAINT "pbx_device_vendor_fu_group_id_67a203de_fk_auth_grou" FOREIGN KEY ("group_id") REFERENCES "auth_group"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_device_vendor_functions" ADD CONSTRAINT "pbx_device_vendor_fu_vendor_id_949d5c05_fk_pbx_devic" FOREIGN KEY ("vendor_id") REFERENCES "pbx_device_vendors"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_devices" ADD CONSTRAINT "pbx_devices_domain_id_id_10d0954a_fk_pbx_domains_id" FOREIGN KEY ("domain_id_id") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_devices" ADD CONSTRAINT "pbx_devices_profile_id_id_d05f3c63_fk_pbx_device_profiles_id" FOREIGN KEY ("profile_id_id") REFERENCES "pbx_device_profiles"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_devices" ADD CONSTRAINT "pbx_devices_user_id_id_bd7443ea_fk_pbx_users_id" FOREIGN KEY ("user_id_id") REFERENCES "pbx_users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_devices" ADD CONSTRAINT "pbx_devices_vendor_id_63e85b1c_fk_pbx_device_vendors_id" FOREIGN KEY ("vendor_id") REFERENCES "pbx_device_vendors"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_dialplan_details" ADD CONSTRAINT "pbx_dialplan_details_dialplan_id_id_eb4dbc17_fk_pbx_dialp" FOREIGN KEY ("dialplan_id_id") REFERENCES "pbx_dialplans"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_dialplan_excludes" ADD CONSTRAINT "pbx_dialplan_excludes_domain_id_id_4ad02574_fk_pbx_domains_id" FOREIGN KEY ("domain_id_id") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_dialplans" ADD CONSTRAINT "pbx_dialplans_domain_id_id_581e14be_fk_pbx_domains_id" FOREIGN KEY ("domain_id_id") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_domain_settings" ADD CONSTRAINT "pbx_domain_settings_domain_id_id_c7461c47_fk_pbx_domains_id" FOREIGN KEY ("domainId") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_domains" ADD CONSTRAINT "pbx_domains_menu_id_id_e5f9f32c_fk_pbx_menus_id" FOREIGN KEY ("menuId") REFERENCES "pbx_menus"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_email_templates" ADD CONSTRAINT "pbx_email_templates_domain_id_id_592ee910_fk_pbx_domains_id" FOREIGN KEY ("domain_id_id") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_extension_users" ADD CONSTRAINT "pbx_extension_users_extension_uuid_68cf4da0_fk_pbx_exten" FOREIGN KEY ("extension_uuid") REFERENCES "pbx_extensions"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_extension_users" ADD CONSTRAINT "pbx_extension_users_user_uuid_c416d33e_fk_pbx_users_user_uuid" FOREIGN KEY ("user_uuid") REFERENCES "pbx_users"("user_uuid") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_extensions" ADD CONSTRAINT "pbx_extensions_domain_uuid_246c1b36_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_follow_me_destinations" ADD CONSTRAINT "pbx_follow_me_destin_extension_uuid_7a65cb1a_fk_pbx_exten" FOREIGN KEY ("extension_uuid") REFERENCES "pbx_extensions"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_gateways" ADD CONSTRAINT "pbx_gateways_domain_uuid_08cbf6c7_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_ivr_menu_options" ADD CONSTRAINT "pbx_ivr_menu_options_ivr_menu_id_id_596a92af_fk_pbx_ivr_m" FOREIGN KEY ("ivr_menu_id_id") REFERENCES "pbx_ivr_menus"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_ivr_menus" ADD CONSTRAINT "pbx_ivr_menus_domain_uuid_82c2bc95_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_menu_item_groups" ADD CONSTRAINT "pbx_menu_item_groups_group_id_727cd142_fk_auth_group_id" FOREIGN KEY ("group_id") REFERENCES "auth_group"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_menu_item_groups" ADD CONSTRAINT "pbx_menu_item_groups_menu_item_id_c543d3d6_fk_pbx_menu_items_id" FOREIGN KEY ("menu_item_id") REFERENCES "pbx_menu_items"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_menu_items" ADD CONSTRAINT "pbx_menu_items_menu_id_a8e4817b_fk_pbx_menus_id" FOREIGN KEY ("menu_id") REFERENCES "pbx_menus"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_menu_items" ADD CONSTRAINT "pbx_menu_items_parent_id_c68849bb_fk_pbx_menu_items_id" FOREIGN KEY ("parent_id") REFERENCES "pbx_menu_items"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_music_on_hold" ADD CONSTRAINT "pbx_music_on_hold_domain_uuid_f5d415b6_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_music_on_hold_files" ADD CONSTRAINT "pbx_music_on_hold_fi_moh_id_id_2ed7958f_fk_pbx_music" FOREIGN KEY ("moh_id_id") REFERENCES "pbx_music_on_hold"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_number_translation_details" ADD CONSTRAINT "pbx_number_translati_number_translation_i_c92ec084_fk_pbx_numbe" FOREIGN KEY ("number_translation_id_id") REFERENCES "pbx_number_translations"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_phrase_details" ADD CONSTRAINT "pbx_phrase_details_phrase_id_id_b0a5c23d_fk_pbx_phrases_id" FOREIGN KEY ("phrase_id_id") REFERENCES "pbx_phrases"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_phrases" ADD CONSTRAINT "pbx_phrases_domain_uuid_3e4927b6_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_recordings" ADD CONSTRAINT "pbx_recordings_domain_uuid_e92a4731_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_ring_group_destinations" ADD CONSTRAINT "pbx_ring_group_desti_ring_group_id_id_b1dd9e79_fk_pbx_ring_" FOREIGN KEY ("ring_group_id_id") REFERENCES "pbx_ring_groups"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_ring_group_users" ADD CONSTRAINT "pbx_ring_group_users_ring_group_id_id_f248dec4_fk_pbx_ring_" FOREIGN KEY ("ring_group_id_id") REFERENCES "pbx_ring_groups"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_ring_group_users" ADD CONSTRAINT "pbx_ring_group_users_user_uuid_78082a94_fk_pbx_users_user_uuid" FOREIGN KEY ("user_uuid") REFERENCES "pbx_users"("user_uuid") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_ring_groups" ADD CONSTRAINT "pbx_ring_groups_domain_uuid_8ee40c93_fk_pbx_domains_id" FOREIGN KEY ("domain_uuid") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_sip_profile_domains" ADD CONSTRAINT "pbx_sip_profile_doma_sip_profile_id_6a5cdae5_fk_pbx_sip_p" FOREIGN KEY ("sip_profile_id") REFERENCES "pbx_sip_profiles"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_sip_profile_settings" ADD CONSTRAINT "pbx_sip_profile_sett_sip_profile_id_3d874090_fk_pbx_sip_p" FOREIGN KEY ("sip_profile_id") REFERENCES "pbx_sip_profiles"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_user_settings" ADD CONSTRAINT "pbx_user_settings_user_id_id_fkey" FOREIGN KEY ("user_id_id") REFERENCES "pbx_users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_users" ADD CONSTRAINT "pbx_users_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_users" ADD CONSTRAINT "pbx_users_auth_user_id_fkey" FOREIGN KEY ("auth_user_id") REFERENCES "auth_user"("uid") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_voicemail_destinations" ADD CONSTRAINT "pbx_voicemail_destin_voicemail_id_id_31053e0d_fk_pbx_voice" FOREIGN KEY ("voicemail_id_id") REFERENCES "pbx_voicemails"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_voicemail_greetings" ADD CONSTRAINT "pbx_voicemail_greeti_voicemail_id_id_ee67c381_fk_pbx_voice" FOREIGN KEY ("voicemail_id_id") REFERENCES "pbx_voicemails"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_voicemail_messages" ADD CONSTRAINT "pbx_voicemail_messag_voicemail_id_id_1f5e00d2_fk_pbx_voice" FOREIGN KEY ("voicemail_id_id") REFERENCES "pbx_voicemails"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_voicemail_options" ADD CONSTRAINT "pbx_voicemail_option_voicemail_id_id_91c19fd9_fk_pbx_voice" FOREIGN KEY ("voicemail_id_id") REFERENCES "pbx_voicemails"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_voicemails" ADD CONSTRAINT "pbx_voicemails_extension_id_id_f5c8e5c1_fk_pbx_extensions_id" FOREIGN KEY ("extension_id_id") REFERENCES "pbx_extensions"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_xml_cdr" ADD CONSTRAINT "pbx_xml_cdr_domain_id_id_ccce6e81_fk_pbx_domains_id" FOREIGN KEY ("domain_id_id") REFERENCES "pbx_domains"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pbx_xml_cdr" ADD CONSTRAINT "pbx_xml_cdr_extension_id_id_f5f7d64e_fk_pbx_extensions_id" FOREIGN KEY ("extension_id_id") REFERENCES "pbx_extensions"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
