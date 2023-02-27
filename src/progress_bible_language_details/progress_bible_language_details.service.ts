import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ProgressBibleLanguageDetail } from '../model/entities';
import { Repository } from 'typeorm';

@Injectable()
export class ProgressBibleLanguageDetailsService {
  constructor(
    @InjectRepository(ProgressBibleLanguageDetail)
    private readonly repo: Repository<ProgressBibleLanguageDetail>,
  ) {}

  public async getAll() {
    return await this.repo.find();
  }

  public async isExist(unit_code: string, primary_country_code: string) {
    return await this.repo.count({
      where: {
        unit_code: unit_code,
        primary_country_code: primary_country_code,
      },
    });
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  public async insert(data: Record<string, any>) {
    return await this.repo.insert({
      unit_code: data.unit_code,
      unit_type: data.unit_type,
      unit_name: data.unit_name,
      unit_full_name: data.unit_full_name,
      ethnologue_name: data.ethnologue_name,
      iso_639_3_code: data.iso_639_3_code,
      is_sign_language: data.is_sign_language,
      code_status: data.code_status,
      language_status: data.language_status,
      language_scope: data.language_scope,
      primary_continent: data.primary_continent,
      primary_country_name: data.primary_country_name,
      primary_country_code: data.primary_country_code,
      retirement_explanation: data.retirement_explanation,
      how_to_fix: data.how_to_fix,
      retired_date: data.retired_date,
      show_active_language: data.show_active_language,
      show_retired_language: data.show_retired_language,
      show_active_dialect: data.show_active_dialect,
      show_retired_dialect: data.show_retired_dialect,
      show_sign_language: data.show_sign_language,
    });
  }
}
