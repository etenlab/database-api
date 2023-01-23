import { Module, Global } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { ProgressBibleLanguageDetailsService } from './progress_bible_language_details.service';
import { ProgressBibleLanguageDetail } from '../model';
import { ProgressBibleLanguageDetailsController } from './progress_bible_language_details.controller';

@Global()
@Module({
  imports: [TypeOrmModule.forFeature([ProgressBibleLanguageDetail])],
  providers: [ProgressBibleLanguageDetailsService],
  controllers: [ProgressBibleLanguageDetailsController],
  exports: [ProgressBibleLanguageDetailsService],
})
export class ProgressBibleLanguageDetailModule {
  constructor(
    private readonly pbLangDetailService: ProgressBibleLanguageDetailsService,
  ) {
    /* initialize logger, or whatever */
  }
}
