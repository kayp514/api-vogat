import 'dotenv/config'
import { defineConfig, env } from 'prisma/config';

export default defineConfig({
  schema: 'prisma-vgt-pbx/schema.prisma',
  migrations: {
    path: 'prisma-vgt-pbx/migrations',
  },
  datasource: {
    url: env('VGT_PBX_DATABASE_URL'),
  },
});