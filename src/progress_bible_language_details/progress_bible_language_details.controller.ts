import { Controller, Get } from '@nestjs/common';
import { ProgressBibleLanguageDetailsService } from './progress_bible_language_details.service';

@Controller('ProgressBibleLanguageDetails')
export class ProgressBibleLanguageDetailsController {
  constructor(private serv: ProgressBibleLanguageDetailsService) {}

  @Get()
  public async getAll() {
    return await this.serv.getAll();
  }
}
