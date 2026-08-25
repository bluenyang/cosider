import {
  EWorkspaceStatus,
  EWorkspaceUserRole,
  type IWorkspaceDetailResponse,
  type IWorkspaceResponse,
} from '@cosider/shared';
import { z } from 'zod';

// zod로 API 응답 런타임 검증 스키마
export const WorkspaceResponseSchema = z.object({
  slug: z.string(),
  name: z.string(),
  status: z.nativeEnum(EWorkspaceStatus),
  description: z.string().nullable(),
  logoImageId: z.uuidv7().nullable(),
  createdAt: z.string(),
  role: z.nativeEnum(EWorkspaceUserRole),
}) satisfies z.ZodType<IWorkspaceResponse>;

export const WorkspaceDetailResponseSchema = WorkspaceResponseSchema.extend({
  owner: z.object({
    handle: z.string(),
    nickname: z.string(),
    profileImageId: z.uuidv7().nullable(),
  }),
  // TODO: 프로젝트 DTO 확정 후 구체적인 타입으로 변경
  projects: z.array(z.record(z.string(), z.unknown())),
}) satisfies z.ZodType<IWorkspaceDetailResponse>;

export const WorkspaceListSchema = z.array(WorkspaceResponseSchema);

export function useWorkspace() {
  const { $api } = useNuxtApp();

  // slug 실시간 중복 확인
  // TODO: debounce 처리 필요 - 컴포넌트에서 호출 시 적용
  async function checkSlugAvailability(slug: string): Promise<boolean> {
    try {
      const data = await $api<{ isAvailable: boolean }>('/api/v1/workspaces/exists/slug', {
        query: { slug },
      });
      return data.isAvailable;
    } catch (error: unknown) {
      const status = (error as { statusCode?: number })?.statusCode;
      if (status === undefined) {
        throw new Error('네트워크 오류가 발생했습니다.', { cause: error });
      }
      return false;
    }
  }

  return {
    checkSlugAvailability,
  };
}
