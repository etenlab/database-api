import { Body, Controller, Post, Query, Res, Response } from '@nestjs/common';
import { ApiBody, ApiParam, ApiProperty } from '@nestjs/swagger';
import { KeycloakService } from '../keycloak/keycloak.service';
import { decode } from 'jsonwebtoken';
import { UserService } from './user.service';

class LoginDTO {
  @ApiProperty()
  login: string;

  @ApiProperty()
  password: string;
}

type JWTAccessTokenPayload = {
  exp: number;
  iat: number;
  jti: string;
  iss: string;
  aud: string;
  sub: string;
  typ: string;
  azp: string;
  session_state: string;
  acr: string;
  'allowed-origins': string[];
  realm_access: {
    roles: string[];
  };
  resource_access: {
    account: {
      roles: string[];
    };
  };
  scope: string;
  sid: string;
  email_verified: true;
  name: string;
  preferred_username: string;
  given_name: string;
  family_name: string;
  email: string;
};

@Controller('users')
export class UserController {
  constructor(
    private readonly keycloakService: KeycloakService,
    private readonly userService: UserService,
  ) {}

  @Post('login')
  async login(
    @Body() body: LoginDTO,
    @Query('realm') realm: string,
    @Res() res: any,
  ) {
    try {
      const response = await this.keycloakService.authenticateUser(
        body.login,
        body.password,
        realm,
      );

      const { data } = response;

      const accessToken = data.access_token;

      const decodedAccessToken = decode(accessToken, { complete: true });

      const payload: JWTAccessTokenPayload = decodedAccessToken?.payload as any;

      const existingUser = await this.userService.ensureUserByEmail({
        email: payload.email,
        isEmailVerified: payload.email_verified,
        username: payload.name,
      });

      const newData = { ...data, user_id: existingUser.id };

      res.status(200);
      res.send(newData);
    } catch (err) {
      res.status(err.response.status);
      res.send(err?.response?.data?.error_description);
    }
  }
}
