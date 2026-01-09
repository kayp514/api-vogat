-- AlterTable
ALTER TABLE "invite" ALTER COLUMN "id" SET DEFAULT 'inv_' || gen_random_uuid();

-- AlterTable
ALTER TABLE "pbx_domains" ADD COLUMN     "ipAddress" VARCHAR(45),
ADD COLUMN     "switchStatus" VARCHAR(20) NOT NULL DEFAULT 'pending';

-- AlterTable
ALTER TABLE "subscription" ALTER COLUMN "id" SET DEFAULT 'sub_' || gen_random_uuid();
