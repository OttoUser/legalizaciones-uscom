import { NextFunction,Response } from 'express'; import jwt from 'jsonwebtoken'; import { Role } from '@prisma/client'; import { AuthRequest } from './types.js';
const secret=()=>{if(!process.env.JWT_SECRET)throw new Error('JWT_SECRET obligatorio');return process.env.JWT_SECRET}; export const token=(id:string,role:Role)=>jwt.sign({id,role},secret(),{expiresIn:'8h'});
export function requireAuth(req:AuthRequest,res:Response,next:NextFunction){try{req.user=jwt.verify((req.headers.authorization||'').replace('Bearer ',''),secret()) as {id:string;role:Role};next()}catch{res.status(401).json({error:'No autorizado'})}}
export const adminOnly=(req:AuthRequest,res:Response,next:NextFunction)=>req.user?.role===Role.ADMIN?next():res.status(403).json({error:'Solo administradores'});
