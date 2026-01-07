-- AlterTable
ALTER TABLE "invite" ALTER COLUMN "id" SET DEFAULT 'inv_' || gen_random_uuid();

-- AlterTable
ALTER TABLE "subscription" ALTER COLUMN "id" SET DEFAULT 'sub_' || gen_random_uuid();

-- CreateTable
CREATE TABLE "pbx_dialplan_defaults" (
    "id" UUID NOT NULL,
    "app_id" UUID NOT NULL,
    "context" VARCHAR(128),
    "category" VARCHAR(32),
    "name" VARCHAR(64),
    "number" VARCHAR(128),
    "destination" VARCHAR(8) NOT NULL,
    "dp_continue" VARCHAR(8) NOT NULL,
    "dp_enabled" VARCHAR(8) NOT NULL,
    "xml" TEXT,
    "sequence" DECIMAL(3,0) NOT NULL,
    "enabled" VARCHAR(8),
    "description" VARCHAR(254),
    "created" TIMESTAMPTZ(6),
    "updated" TIMESTAMPTZ(6),
    "synchronised" TIMESTAMPTZ(6),
    "updated_by" VARCHAR(64) NOT NULL,

    CONSTRAINT "pbx_dialplan_defaults_pkey" PRIMARY KEY ("id")
);
