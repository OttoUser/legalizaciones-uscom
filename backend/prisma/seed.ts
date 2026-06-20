import { PrismaClient, Role } from '@prisma/client'; import bcrypt from 'bcrypt'; import 'dotenv/config';
const prisma=new PrismaClient();
async function main(){const {ADMIN_USERNAME,ADMIN_EMAIL,ADMIN_PASSWORD}=process.env;if(!ADMIN_USERNAME||!ADMIN_EMAIL||!ADMIN_PASSWORD) throw new Error('ADMIN_USERNAME, ADMIN_EMAIL y ADMIN_PASSWORD son obligatorios'); await prisma.user.upsert({where:{email:ADMIN_EMAIL},update:{},create:{username:ADMIN_USERNAME,email:ADMIN_EMAIL,passwordHash:await bcrypt.hash(ADMIN_PASSWORD,12),role:Role.ADMIN}})}
main().finally(()=>prisma.$disconnect());
