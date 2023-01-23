import {
  Field,
  InputType,
  Int,
  ObjectType,
  registerEnumType,
} from '@nestjs/graphql';

@ObjectType()
export class EntityAddress {
  @Field((type) => Int) i: number;
  @Field((type) => Int) c: number;
}

@InputType()
export class GenericInput {
  @Field() readonly id: number;
}

@ObjectType()
export class GenericOutput {
  @Field((type) => ErrorType) readonly error: ErrorType;
}

export enum ErrorType {
  NoError = 'NoError',
  TokenInvalid = 'TokenInvalid',
  Unauthorized = 'Unauthorized',
  UnknownError = 'UnknownError',
}

registerEnumType(ErrorType, {
  name: 'ErrorType',
});
