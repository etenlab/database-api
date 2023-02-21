import { Query, Resolver } from '@nestjs/graphql';
import { PostgresService } from '../core/postgres.service';
import { ErrorType, GenericOutput } from '../common/types';
@Resolver(GenericOutput)
export class GenericResolver {
  constructor(private pg: PostgresService) {}

  @Query(() => GenericOutput)
  async asdf(): Promise<GenericOutput> {
    console.log('generic resolver');
    try {
      return {
        error: ErrorType.NoError,
      };
    } catch (e) {
      console.error(e);
    }

    return {
      error: ErrorType.UnknownError,
    };
  }
}
