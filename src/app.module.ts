import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { Module } from "@nestjs/common";
import { GraphQLModule } from '@nestjs/graphql';
import { HttpModule, HttpService } from '@nestjs/axios';
import { join } from 'path';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CoreModule } from './core/core.module';
import { ScheduleModule } from '@nestjs/schedule';
import { CronService } from './cron/cron.service';
import { ConfigModule, ConfigService } from '@nestjs/config';
import {TypeOrmModule} from '@nestjs/typeorm';
import { ProgressBibleLanguageDetailsService } from './progress_bible_language_details/progress_bible_language_details.service';
import { ProgressBibleLanguageDetailModule } from './progress_bible_language_details/progress_bible_language_details.module';
import { ProgressBibleLanguageDetail } from './model';
import { entities } from './model/index';

@Module({
  imports: [
    ProgressBibleLanguageDetailModule,
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST'),
        port: configService.get<number>('DB_PORT'),
        username: configService.get('DB_USERNAME'),
        password: configService.get('DB_PASSWORD'),
        database: configService.get('DB_NAME'),
        entities: [...entities],
        synchronize: false,
      }),
      inject: [ConfigService],
    }),
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: join(process.cwd(), 'src/schema.gql'),
      sortSchema: true
    }),
    CoreModule,
    HttpModule,
    ScheduleModule.forRoot()
  ],
  controllers: [AppController],
  providers: [AppService, CronService],
  // entities: [ProgressBibleLanguageDetail],
  exports: [

  ]
})
export class AppModule { 
  constructor(private readonly config: ConfigService){}
}
