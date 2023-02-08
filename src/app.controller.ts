import { Controller, Get } from '@nestjs/common';
import { readFileSync } from 'fs';
import { resolve } from 'path';
import { AppService } from './app.service';

const pkg = readFileSync(resolve(process.cwd(), 'package.json'));
const { verions, name } = JSON.parse(pkg.toString()).version;

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('version')
  getVersion() {
    return { verions, name };
  }
}
