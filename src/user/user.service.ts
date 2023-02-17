import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Users } from '../model/entities';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(Users)
    private readonly userRepository: Repository<Users>,
  ) {}

  async ensureUserByEmail(
    userData: Pick<Users, 'email' | 'isEmailVerified' | 'username'>,
  ): Promise<Users> {
    const upsertResult = await this.userRepository.upsert(
      { ...userData, active: true, password: 'placeholder' },
      {
        conflictPaths: ['email'],
        skipUpdateIfNoValuesChanged: true,
      },
    );

    const user = await this.userRepository.findOne({
      where: { email: userData.email },
    });

    return user!;
  }
}
