import { HttpService } from '@nestjs/axios';
import { Body, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class KeycloakService {
  private keycloakUrl: string;
  private keycloakClientId: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly httpService: HttpService,
  ) {
    this.keycloakUrl = this.configService.get('KEYCLOAK_URL')!;
    this.keycloakClientId = this.configService.get('KEYCLOAK_CLIENT_ID')!;

    if (!this.keycloakUrl || !this.keycloakClientId) {
      throw new Error(
        'Keycloak configuration is missing. Provide KEYCLOAK_URL, KEYCLOAK_REALM and KEYCLOAK_CLIENT_ID environment variables. ',
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
}
