import {
  BadRequestException,
  Body,
  Controller,
  Get,
  NotFoundException,
  Param,
  Patch,
  Post,
  Put,
  Req,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { OAuth2Client } from 'google-auth-library';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard.js';
import { User } from '../users/user.entity.js';
import { Job } from '../jobs/job.entity.js';
import { Application } from '../applications/application.entity.js';
import { MobileMessagesService } from './mobile-messages.service.js';

@Controller('api')
export class MobileApiController {
  constructor(
    @InjectRepository(User) private readonly usersRepo: Repository<User>,
    @InjectRepository(Job) private readonly jobsRepo: Repository<Job>,
    @InjectRepository(Application)
    private readonly appsRepo: Repository<Application>,
    private readonly jwtService: JwtService,
    private readonly messagesService: MobileMessagesService,
  ) {}

  private readonly googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

  private mapUser(user: User) {
    return {
      id: user.userId,
      role: user.role,
      name: user.fullName,
      email: user.email,
      photoUrl: user.avatarUrl,
      phone: user.phone,
      gender: null,
      dob: null,
      address: user.location,
      title: null,
      about: user.registrationData || null,
      skills: [],
      educationJson: null,
      experienceJson: null,
      socialLinksJson: null,
      portfolioImagesJson: null,
    };
  }

  private createToken(user: User): string {
    return this.jwtService.sign({
      sub: user.userId,
      email: user.email,
      role: user.role,
      name: user.fullName,
      avatar: user.avatarUrl,
      phone: user.phone || null,
      location: user.location || null,
      classification: user.classification || null,
    });
  }

  @Post('auth/login')
  async login(
    @Body() body: { email: string; password: string; role?: string },
  ) {
    const email = body.email?.trim().toLowerCase();
    if (!email || !body.password) {
      throw new BadRequestException('Email and password are required');
    }

    const user = await this.usersRepo.findOne({ where: { email } });
    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordOk = await bcrypt.compare(body.password, user.passwordHash);
    if (!passwordOk) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const expectedRole = body.role?.trim().toLowerCase();
    if (expectedRole === 'company' && user.role !== 'company') {
      throw new UnauthorizedException('Account is not a company account');
    }
    if (expectedRole && expectedRole !== 'company' && user.role === 'company') {
      throw new UnauthorizedException('Company account is not allowed here');
    }

    return {
      token: this.createToken(user),
      user: this.mapUser(user),
    };
  }

  @Post('auth/google')
  async googleLogin(@Body() body: { idToken: string }) {
    if (!body.idToken) {
      throw new BadRequestException('idToken is required');
    }

    const ticket = await this.googleClient.verifyIdToken({
      idToken: body.idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    if (!payload?.email) {
      throw new UnauthorizedException('Invalid Google token');
    }

    const email = payload.email.toLowerCase();
    let user = await this.usersRepo.findOne({ where: { email } });
    if (!user) {
      const createdUser: Partial<User> = {
        email,
        fullName: payload.name || email.split('@')[0],
        role: 'user',
        isActive: true,
        googleId: payload.sub || null,
        avatarUrl: payload.picture || undefined,
      };
      user = await this.usersRepo.save(createdUser);
    }

    return { token: this.createToken(user), user: this.mapUser(user) };
  }

  @Post('auth/register')
  async register(
    @Body() body: { email: string; password: string; name: string; role: string },
  ) {
    const email = body.email?.trim().toLowerCase();
    if (!email || !body.password || !body.name || !body.role) {
      throw new BadRequestException('email, password, name and role are required');
    }
    const exists = await this.usersRepo.findOne({ where: { email } });
    if (exists) {
      throw new BadRequestException('Email already exists');
    }

    const hash = await bcrypt.hash(body.password, 10);
    const user = await this.usersRepo.save(
      this.usersRepo.create({
        email,
        passwordHash: hash,
        fullName: body.name.trim(),
        role: body.role.trim().toLowerCase(),
        isActive: true,
      }),
    );

    return { token: this.createToken(user), user: this.mapUser(user) };
  }

  @UseGuards(JwtAuthGuard)
  @Get('auth/profile')
  async getProfile(@Req() req: any) {
    const user = await this.usersRepo.findOne({ where: { userId: req.user.sub } });
    if (!user) throw new NotFoundException('User not found');
    return this.mapUser(user);
  }

  @UseGuards(JwtAuthGuard)
  @Put('auth/profile')
  async updateProfile(@Req() req: any, @Body() body: Record<string, unknown>) {
    const user = await this.usersRepo.findOne({ where: { userId: req.user.sub } });
    if (!user) throw new NotFoundException('User not found');

    if (typeof body.name === 'string') user.fullName = body.name;
    if (typeof body.photoUrl === 'string') user.avatarUrl = body.photoUrl;
    if (typeof body.phone === 'string') user.phone = body.phone;
    if (typeof body.address === 'string') user.location = body.address;
    if (typeof body.location === 'string') user.location = body.location;
    if (typeof body.about === 'string') user.registrationData = body.about;

    const saved = await this.usersRepo.save(user);
    return this.mapUser(saved);
  }

  @UseGuards(JwtAuthGuard)
  @Get('jobs')
  async listJobs() {
    const jobs = await this.jobsRepo.find({
      relations: ['company', 'user', 'applications'],
      order: { updatedAt: 'DESC' },
    });
    return jobs.map((job) => ({
      id: String(job.jobId),
      title: job.title,
      companyId: job.companyId ? String(job.companyId) : null,
      companyName: job.company?.name || job.user?.fullName || 'Unknown',
      location: job.address || '',
      salaryRange:
        job.salaryMin && job.salaryMax
          ? `${job.salaryMin}-${job.salaryMax}`
          : job.salary?.toString() || 'Negotiable',
      type: job.jobType || 'Full-time',
      description: job.description || '',
      responsibilities: [],
      qualifications: [],
      niceToHaves: [],
      benefits: [],
      classification: job.classification || 'General',
      tags: [],
      createdAt: job.createdAt,
      requiredCount: job.slotsAvailable || 1,
      acceptedCount:
        job.applications?.filter((a) =>
          (a.status || '').toLowerCase().includes('accept'),
        ).length || 0,
      deadline: job.expiresAt,
      status: job.isActive ? 'Open' : 'Closed',
      viewsCount: 0,
    }));
  }

  @UseGuards(JwtAuthGuard)
  @Post('jobs')
  async createJob(@Req() req: any, @Body() body: Record<string, any>) {
    const user = await this.usersRepo.findOne({ where: { userId: req.user.sub } });
    if (!user) throw new UnauthorizedException();
    if (user.role !== 'company') {
      throw new UnauthorizedException('Only company users can create jobs');
    }

    const [salaryMin, salaryMax] = String(body.salaryRange || '')
      .split('-')
      .map((v) => Number(v.trim()))
      .filter((v) => !Number.isNaN(v));

    const createdJob: Partial<Job> = {
      title: body.title,
      companyId: null,
      userId: user.userId,
      address: body.location || '',
      description: body.description || '',
      salaryMin: salaryMin || undefined,
      salaryMax: salaryMax || undefined,
      jobType: body.type || 'full-time',
      classification: body.classification || 'General',
      slotsAvailable: Number(body.requiredCount || 1),
      isActive: true,
      expiresAt: body.deadline ? new Date(body.deadline) : undefined,
    };
    const job = await this.jobsRepo.save(createdJob);

    return { id: String(job.jobId) };
  }

  @UseGuards(JwtAuthGuard)
  @Put('jobs/:id')
  async updateJob(
    @Req() req: any,
    @Param('id') id: string,
    @Body() body: Record<string, any>,
  ) {
    const user = await this.usersRepo.findOne({ where: { userId: req.user.sub } });
    if (!user) throw new UnauthorizedException();
    const job = await this.jobsRepo.findOne({ where: { jobId: Number(id) } });
    if (!job) throw new NotFoundException('Job not found');
    if (job.userId !== user.userId) {
      throw new UnauthorizedException('Not allowed');
    }

    if (typeof body.title === 'string') job.title = body.title;
    if (typeof body.location === 'string') job.address = body.location;
    if (typeof body.description === 'string') job.description = body.description;
    if (typeof body.type === 'string') job.jobType = body.type;
    if (typeof body.classification === 'string') {
      job.classification = body.classification;
    }
    if (typeof body.requiredCount !== 'undefined') {
      job.slotsAvailable = Number(body.requiredCount || 1);
    }
    if (typeof body.status === 'string') {
      job.isActive = body.status.toLowerCase() !== 'closed';
    }
    if (typeof body.deadline === 'string') {
      job.expiresAt = new Date(body.deadline);
    }

    await this.jobsRepo.save(job);
    return { id: String(job.jobId) };
  }

  @UseGuards(JwtAuthGuard)
  @Post('applications')
  async createApplication(
    @Req() req: any,
    @Body() body: { jobId: string; userName?: string },
  ) {
    const user = await this.usersRepo.findOne({ where: { userId: req.user.sub } });
    if (!user) throw new UnauthorizedException();
    const jobId = Number(body.jobId);
    if (!jobId) throw new BadRequestException('jobId is required');
    const job = await this.jobsRepo.findOne({ where: { jobId } });
    if (!job) throw new NotFoundException('Job not found');

    const exists = await this.appsRepo.findOne({
      where: { jobId, userId: user.userId },
    });
    if (exists) {
      throw new BadRequestException('You have already applied for this job');
    }

    const app = await this.appsRepo.save(
      this.appsRepo.create({
        jobId,
        userId: user.userId,
        status: 'Applied',
        coverLetter: '',
        address: '',
        resumeUrl: '',
        portfolioUrl: '',
      }),
    );

    return {
      id: String(app.applicationId),
      userId: user.userId,
      userName: body.userName || user.fullName,
      jobId: String(app.jobId),
      status: app.status,
      updatedAt: app.appliedAt,
    };
  }

  @UseGuards(JwtAuthGuard)
  @Get('applications')
  async listApplications() {
    const apps = await this.appsRepo.find({
      relations: ['user'],
      order: { appliedAt: 'DESC' },
    });
    return apps.map((a) => ({
      id: String(a.applicationId),
      userId: a.userId,
      userName: a.user?.fullName || 'Unknown',
      jobId: String(a.jobId),
      status: a.status,
      updatedAt: a.appliedAt,
    }));
  }

  @UseGuards(JwtAuthGuard)
  @Patch('applications/:id/status')
  async updateApplicationStatus(
    @Req() req: any,
    @Param('id') id: string,
    @Body() body: { status: string },
  ) {
    const user = await this.usersRepo.findOne({ where: { userId: req.user.sub } });
    if (!user || user.role !== 'company') {
      throw new UnauthorizedException('Only company users can update status');
    }

    const app = await this.appsRepo.findOne({
      where: { applicationId: Number(id) },
      relations: ['user'],
    });
    if (!app) throw new NotFoundException('Application not found');
    app.status = body.status || 'In Review';
    await this.appsRepo.save(app);

    return {
      id: String(app.applicationId),
      userId: app.userId,
      userName: app.user?.fullName || 'Unknown',
      jobId: String(app.jobId),
      status: app.status,
      updatedAt: app.appliedAt,
    };
  }

  @UseGuards(JwtAuthGuard)
  @Get('messages')
  listMessages() {
    return this.messagesService.list();
  }

  @UseGuards(JwtAuthGuard)
  @Post('messages')
  createMessage(@Req() req: any, @Body() body: { text: string }) {
    return this.messagesService.add(req.user?.role === 'company', body.text || '');
  }
}
