import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from '../users/user.entity.js';
import { Job } from '../jobs/job.entity.js';
import { Application } from '../applications/application.entity.js';
import { MobileApiController } from './mobile-api.controller.js';
import { MobileMessagesService } from './mobile-messages.service.js';

@Module({
  imports: [
    ConfigModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET') || 'your-secret-key',
        signOptions: { expiresIn: '7d' },
      }),
    }),
    TypeOrmModule.forFeature([User, Job, Application]),
  ],
  controllers: [MobileApiController],
  providers: [MobileMessagesService],
})
export class MobileApiModule {}
