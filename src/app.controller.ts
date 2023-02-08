import { Controller, Get } from '@nestjs/common';
import { readFileSync } from 'fs';
import { resolve } from 'path';
import { AppService } from './app.service';

const pkg = readFileSync(resolve(process.cwd(), 'package.json'));
const { version, name } = JSON.parse(pkg.toString());

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('info')
  getVersion() {
    console.log({ version, name });
    return { version, name };
  }
}
