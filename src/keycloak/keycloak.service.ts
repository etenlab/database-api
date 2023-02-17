import { HttpService } from '@nestjs/axios';
import { Body, Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { map } from 'rxjs';
import { catchError } from 'rxjs/operators';

export interface RegisterRequest {
  email: string;
  password: string;
  username: string;
}

@Injectable()
export class KeycloakService {
  private keycloakUrl: string;
  private keycloakClientId: string;
  private keycloakClientSecret: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly httpService: HttpService,
  ) {
    this.keycloakUrl = this.configService.get('KEYCLOAK_URL')!;
    this.keycloakClientId = this.configService.get('KEYCLOAK_CLIENT_ID')!;
    this.keycloakClientSecret = this.configService.get(
      'KEYCLOAK_CLIENT_SECRET',
    )!;

    if (
      !this.keycloakUrl ||
      !this.keycloakClientId ||
      !this.keycloakClientSecret
    ) {
      throw new HttpException(
        'Internal Server Error',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  // Resource Owner Password Flow
  public async authenticateUser(
    login: string,
    password: string,
    realm: string,
  ): Promise<any> {
    const url = `${this.keycloakUrl}/realms/${realm}/protocol/openid-connect/token`;

    const body = `client_id=${this.keycloakClientId}&grant_type=password&password=${password}&username=${login}`;

    return await this.httpService.axiosRef.post(url, body, {});
  }

  public async getToken(realm: string): Promise<any> {
    const url = `${this.keycloakUrl}/realms/${realm}/protocol/openid-connect/token`;

    const body = new URLSearchParams();
    body.set('grant_type', 'client_credentials');
    body.set('client_id', this.keycloakClientId);
    body.set('client_secret', this.keycloakClientSecret);

    const headers = {
      'Content-Type': `application/x-www-form-urlencoded`,
    };

    return await this.httpService
      .post<any>(url, body.toString(), { headers })
      .pipe(
        map(async (response) => {
          return response.data.access_token;
        }),
      )
      .pipe(
        catchError((error) => {
          console.log(error);
          throw new HttpException(error.response.data, error.response.status);
        }),
      )
      .toPromise();
  }

  async createUser(
    token: string,
    body: RegisterRequest,
    realm: string,
  ): Promise<any> {
    const params = {
      email: body.email,
      username: body.email,
      emailVerified: true,
      enabled: true,
      credentials: [
        {
          type: 'password',
          value: body.password,
          temporary: false,
        },
      ],
    };

    const headers = {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    };

    return await this.httpService
      .post(`${this.keycloakUrl}/admin/realms/${realm}/users`, params, {
        headers,
      })
      .pipe(
        map((resp) => {
          return resp.data;
        }),
      )
      .pipe(
        catchError((error) => {
          throw new HttpException(error.response.data, error.response.status);
        }),
      )
      .toPromise();
  }
}
