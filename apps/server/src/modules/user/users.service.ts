import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { eq } from 'drizzle-orm';

import { UserProfileResponse } from './dto';

import { DB_CONNECTION } from '@/common/constants';
import { UNAVAILABLE_HANDLES } from '@/common/constants/user.const';
import { CheckExistsResponse } from '@/common/model';
import type { DrizzleDB } from '@/database/drizzle.module';
import { userProfiles, users } from '@/database/schema/user.schema';

@Injectable()
export class UsersService {
  constructor(
    @Inject(DB_CONNECTION)
    private readonly db: DrizzleDB,
  ) {}

  // 프로필 조회
  async getProfile(handle: string): Promise<UserProfileResponse> {
    const [profile] = await this.db
      .select()
      .from(users)
      .innerJoin(userProfiles, eq(users.id, userProfiles.userId))
      .where(eq(userProfiles.handle, handle))
      .limit(1);

    // 프로필이 없을 경우 404 반환
    if (!profile) {
      throw new NotFoundException('USER_NOT_FOUND');
    }

    return {
      handle: profile.user_profiles.handle,
      nickname: profile.user_profiles.nickname ?? '',
      techStacks: profile.user_profiles.techStacks as string[] | null,
      jobRole: profile.user_profiles.jobRole,
      profileImageId: profile.user_profiles.profileImageId,
    } satisfies UserProfileResponse;
  }

  async checkHandleExists(handle: string): Promise<CheckExistsResponse> {
    if (UNAVAILABLE_HANDLES.has(handle.toLowerCase())) {
      return { isAvailable: false };
    }

    const [profile] = await this.db
      .select({ id: userProfiles.id })
      .from(userProfiles)
      .where(eq(userProfiles.handle, handle))
      .limit(1);

    return {
      isAvailable: !profile,
    };
  }
}
