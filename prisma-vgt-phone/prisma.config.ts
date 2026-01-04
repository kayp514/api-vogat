import 'dotenv/config'
import { defineConfig, env } from 'prisma/config';

export default defineConfig({
  schema: 'prisma-vgt-phone/schema.prisma',
  migrations: {
    path: 'prisma-vgt-phone/migrations'
  },
  datasource: {
    url: env('VGT_PHONE_DATABASE_URL'),
  },
});