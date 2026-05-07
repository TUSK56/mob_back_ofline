import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from '../users/user.entity.js';
import { Job } from '../jobs/job.entity.js';
import { Application } from '../applications/application.entity.js';
import { MobileApiController } from './mobile-api.controller.js';
import { MobileMessagesService } from './mobile-messages.service.js';

@Module({
  imports: [JwtModule, TypeOrmModule.forFeature([User, Job, Application])],
  controllers: [MobileApiController],
  providers: [MobileMessagesService],
})
export class MobileApiModule {}
