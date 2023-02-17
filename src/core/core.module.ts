import { Module } from '@nestjs/common';
import { DatabaseVersionControlService } from './database-version-control.service';
import { GenericResolver } from './generic.resolver';
import { PostgresService } from './postgres.service';

@Module({
  imports: [],
  providers: [PostgresService, DatabaseVersionControlService, GenericResolver],
  exports: [PostgresService, DatabaseVersionControlService, GenericResolver],
})
export class CoreModule {}
