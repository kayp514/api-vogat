-- AlterTable
ALTER TABLE "auth_user" ADD COLUMN     "isAdmin" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "isStaff" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "isSuperuser" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable
ALTER TABLE "invite" ALTER COLUMN "id" SET DEFAULT 'inv_' || gen_random_uuid();

-- AlterTable
ALTER TABLE "subscription" ALTER COLUMN "id" SET DEFAULT 'sub_' || gen_random_uuid();
