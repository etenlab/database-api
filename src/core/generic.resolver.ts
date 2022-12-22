import { Args, Context, GqlContextType, Int, Mutation, Query, Resolver } from "@nestjs/graphql";
import { ApolloError } from "apollo-server-express";
import { createToken, getBearer, validateEmail } from "../common/utility";
import { PostgresService } from "../core/postgres.service";
import { hash } from "argon2"
import { ErrorType, GenericInput, GenericOutput } from "../common/types";
@Resolver(GenericOutput)
export class GenericResolver {
  constructor(
    private pg: PostgresService,
  ) { }

  @Query(returns => GenericOutput)
  async asdf(@Args('input') input: GenericInput, @Context() req: any): Promise<GenericOutput> {
    console.log("generic resolver")
    try {
      return {
        error: ErrorType.NoError
      }
    } catch (e) {
      console.error(e)
    }

    return {
      error: ErrorType.UnknownError,
    }
  }
}