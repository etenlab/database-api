import { HttpService } from '@nestjs/axios';
import { Injectable, HttpException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { map } from 'rxjs';
import { catchError } from 'rxjs/operators';
import type { AxiosResponse } from 'axios';

export interface RegisterRequest {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
}

@Injectable()
export class KeycloakService {
  private keycloakUrl: string;
  private keycloakRealm: string;
  private keycloakClients: { id: string; secret: string }[];

  constructor(
    private readonly configService: ConfigService,
    private readonly httpService: HttpService,
  ) {
    this.keycloakUrl = this.configService.get('KEYCLOAK_URL') || '';
    this.keycloakRealm = this.configService.get('KEYCLOAK_REALM') || '';

    if (!this.keycloakUrl) {
      throw new Error('Missing env var KEYCLOAK_URL');
    }

    if (!this.keycloakRealm) {
      throw new Error('Missing env var KEYCLOAK_REALM');
    }

    // clients by pattern: client_id1:secret1,client_id2:secret2
    const clients = this.configService.get('KEYCLOAK_CLIENTS') || '';

    this.keycloakClients = clients.split(',').map((client: string) => {
      const [id, secret] = client.split(':');
      return { id, secret };
    });
  }

  // Resource Owner Password Flow
  public async authenticateUser(
    login: string,
    password: string,
    clientId: string,
  ): Promise<AxiosResponse> {
    const url = `${this.keycloakUrl}/realms/${this.keycloakRealm}/protocol/openid-connect/token`;

    const body = `client_id=${clientId}&grant_type=password&password=${password}&username=${login}`;

    return await this.httpService.axiosRef.post(url, body, {});
  }

  // Commenting this out because we're not using it
  // public async getToken(realm: string): Promise<any> {
  //   const url = `${this.keycloakUrl}/realms/${realm}/protocol/openid-connect/token`;

  //   const params = {
  //     grant_type: 'client_credentials',
  //     client_id: this.keycloakClientId,
  //     client_secret: this.keycloakClientSecret,
  //   };

  //   const config = {
  //     headers: {
  //       'Content-Type': `application/x-www-form-urlencoded`,
  //     },
  //   };

  //   return await this.httpService
  //     .post<any>(url, params, config)
  //     .pipe(
  //       map(async (response) => {
  //         return response.data.access_token;
  //       }),
  //     )
  //     .pipe(
  //       catchError((error) => {
  //         throw new HttpException(error.response.data, error.response.status);
  //       }),
  //     )
  //     .toPromise();
  // }

  async createUser(
    token: string,
    request: RegisterRequest,
    realm: string,
  ): Promise<{
    // Todo: specify the type
    [key: string]: string;
  }> {
    const params = JSON.stringify({
      firstName: request.firstName,
      lastName: request.lastName,
      email: request.email,
      username: request.email,
      emailVerified: true,
      enabled: true,
      credentials: [
        {
          type: 'password',
          value: request.password,
          temporary: false,
        },
      ],
    });

    const config = {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    };

    return this.httpService
      .post(`${this.keycloakUrl}/admin/realms/${realm}/users`, params, config)
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
