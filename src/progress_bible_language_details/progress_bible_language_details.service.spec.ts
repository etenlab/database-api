import { Test, TestingModule } from '@nestjs/testing';
import { ProgressBibleLanguageDetailsService } from './progress_bible_language_details.service';

describe('ProgressBibleLanguageDetailsService', () => {
  let service: ProgressBibleLanguageDetailsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ProgressBibleLanguageDetailsService],
    }).compile();

    service = module.get<ProgressBibleLanguageDetailsService>(
      ProgressBibleLanguageDetailsService,
    );
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
