import { Injectable, Logger, Module } from '@nestjs/common';
// import { Cron } from '@nestjs/schedule'
import { HttpService } from '@nestjs/axios';
import { ProgressBibleLanguageDetailsService } from '../progress_bible_language_details/progress_bible_language_details.service';
import { ProgressBibleLanguageDetailModule } from '../progress_bible_language_details/progress_bible_language_details.module';
// import { ProgressBibleLanguageDetail } from '../model';

@Module({
  imports: [ProgressBibleLanguageDetailModule],
})
@Injectable()
export class CronService {
  // private readonly logger = new Logger(CronService.name);
  //
  // constructor(private readonly httpService: HttpService, private pbLangDetailService: ProgressBibleLanguageDetailsService) {}

  // @Cron('0 1 * * * *')
  async handleCron() {
    // this.logger.debug('Called when the current second is 45');
    /*
    const { createHmac } = await import('node:crypto');
    const util = require('util')

    
    var apiKey = '00c96ddca3d86a96d15ecc7cf2af1ecc'; // insert Key Value received from API Developer Portal.
    var sharedSecret = '22d04c4562fa4492f382aa914b04a120ddc85d63cc357e39033919846fd2c32747c99387d7c1c30d90624a625ceb43e43dcb143ab5f3378d9e1449a59ee7af15'; // insert Key Secret received from API Developer Portal. 
    
    var unixTimestamp = Math.floor(Date.now() / 1000);
    var hmac = createHmac('sha1', sharedSecret);
    var signature = hmac.update(unixTimestamp + apiKey).digest('hex');
    var url = 'https://progressbible-language-v1.apis.sil.org?api_key='+apiKey+'&api_sig='+signature;
    var result = this.httpService.get(url);
    
    result.forEach(value => {
      console.log(value.status);
      if(value.status == 200){
        value.data.resource.forEach( async (entry: any) => {
          var count = await this.pbLangDetailService.isExist(entry.UnitCode, entry.PrimaryCountryCode)
          // console.log(count);
          if (!count){
            // console.log(entry);
            await this.pbLangDetailService.insert({
              unit_code: entry.UnitCode,
              unit_type: entry.UnitType,
              unit_name: entry.UnitName,
              unit_full_name: entry.UnitFullName,
              ethnologue_name: entry.EthnologueName,
              iso_639_3_code: entry.ISO_639_3Code,
              is_sign_language: entry.IsSignLanguage,
              code_status: entry.CodeStatus,
              language_status: entry.LanguageStatus,
              language_scope: entry.LanguageScope,
              primary_continent: entry.PrimaryContinent,
              primary_country_name: entry.PrimaryCountryName,
              primary_country_code: entry.PrimaryCountryCode,
              retirement_explanation: entry.RetirementExplanation,
              how_to_fix: entry.HowToFix,
              retired_date: entry.RetiredDate,
              show_active_language: entry.ShowActiveLanguage,
              show_retired_language: entry.ShowRetiredLanguage,
              show_active_dialect: entry.ShowActiveDialect,
              show_retired_dialect: entry.ShowRetiredDialect,
              show_sign_language: entry.ShowSignLanguage
            });
          }
        })
      }
      // console.log(value.data.resource )
    })
    */
    // var data = await this.pbLangDetailService.getAll()
    // if(data.length){
    //   data.forEach((value:ProgressBibleLanguageDetail, index: number) => {
    //   })
    // }
    // console.log(data)
    //this.logger.debug(util.inspect(result, {showHidden: false, depth: null, colors: true}));
  }
}
