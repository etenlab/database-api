import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { Module } from '@nestjs/common';
import { GraphQLModule } from '@nestjs/graphql';
import { HttpModule } from '@nestjs/axios';
import { join } from 'path';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CoreModule } from './core/core.module';
import { ScheduleModule } from '@nestjs/schedule';
import { CronService } from './cron/cron.service';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProgressBibleLanguageDetailModule } from './progress_bible_language_details/progress_bible_language_details.module';
import { UserController } from './user/user.controller';
import { UserService } from './user/user.service';
import { KeycloakService } from './keycloak/keycloak.service';
import entities from './model/entities';

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
        schema: configService.get('DB_SCHEMA') || 'public',
        entities,
        synchronize: false,
      }),
      inject: [ConfigService],
    }),
    TypeOrmModule.forFeature(entities),
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: join(process.cwd(), 'src/schema.gql'),
      sortSchema: true,
    }),
    CoreModule,
    HttpModule,
    ScheduleModule.forRoot(),
  ],
  controllers: [AppController, UserController],
  providers: [AppService, CronService, UserService, KeycloakService],
  // entities: [ProgressBibleLanguageDetail],
  exports: [],
})
export class AppModule {
  constructor(private readonly config: ConfigService) {
    console.log(process.env.DB_USERNAME);
    console.log(process.env.DB_USERNAME);
  }
}
