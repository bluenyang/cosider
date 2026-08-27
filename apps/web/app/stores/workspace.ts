import type {
  ICreateWorkspaceRequest,
  IWorkspaceDetailResponse,
  IWorkspaceResponse,
} from '@cosider/shared';
import { defineStore } from 'pinia';

import {
  WorkspaceDetailResponseSchema,
  WorkspaceListSchema,
  WorkspaceResponseSchema,
} from '~/composables/use-workspace';

export const useWorkspaceStore = defineStore('workspace', () => {
  const { $api } = useNuxtApp();
  const toast = useToast();

  const workspaces = ref<IWorkspaceResponse[]>([]);
  const isLoading = ref(false);

  /** Shell display contract — routing stays with feature owners. */
  const currentSlug = ref<string | null>(null);
  const currentWorkspaceDetail = ref<IWorkspaceDetailResponse | null>(null);

  const currentWorkspace = computed(() => {
    if (currentSlug.value) {
      const matched = workspaces.value.find((ws) => ws.slug === currentSlug.value);
      if (matched) return matched;
    }
    return workspaces.value[0] ?? null;
  });

  function setCurrent(slug: string | null) {
    currentSlug.value = slug;
  }

  // 워크스페이스 목록 조회
  async function fetchWorkspaces() {
    isLoading.value = true;
    try {
      const data = await $api<IWorkspaceResponse[]>('/api/v1/workspaces');
      workspaces.value = WorkspaceListSchema.parse(data) as IWorkspaceResponse[];
    } catch {
      toast.add({
        title: '오류',
        description: '워크스페이스 목록을 불러오지 못했습니다.',
        color: 'error',
      });
    } finally {
      isLoading.value = false;
    }
  }

  // 워크스페이스 생성
  async function createWorkspace(payload: ICreateWorkspaceRequest): Promise<boolean> {
    try {
      const data = await $api<IWorkspaceResponse>('/api/v1/workspaces', {
        method: 'POST',
        body: payload,
      });
      WorkspaceResponseSchema.parse(data);
      workspaces.value = [...workspaces.value, data as IWorkspaceResponse];
      setCurrent(data.slug);
      toast.add({
        title: '성공',
        description: '워크스페이스가 생성되었습니다.',
        color: 'success',
      });
      return true;
    } catch (error: unknown) {
      const status = (error as { statusCode?: number })?.statusCode;
      const description =
        status === 409 ? 'slug가 이미 사용 중입니다.' : '워크스페이스 생성에 실패했습니다.';
      toast.add({ title: '오류', description, color: 'error' });
      return false;
    }
  }

  // 워크스페이스 상세 조회
  async function fetchWorkspaceDetail(slug: string) {
    isLoading.value = true;
    try {
      const data = await $api<IWorkspaceDetailResponse>(`/api/v1/workspaces/${slug}`);
      currentWorkspaceDetail.value = WorkspaceDetailResponseSchema.parse(
        data,
      ) as IWorkspaceDetailResponse;
    } catch {
      toast.add({
        title: '오류',
        description: '워크스페이스 정보를 불러오지 못했습니다.',
        color: 'error',
      });
    } finally {
      isLoading.value = false;
    }
  }

  // 워크스페이스 로고 수정
  async function updateWorkspaceLogo(slug: string, uploadToken: string): Promise<boolean> {
    try {
      await $api(`/api/v1/workspaces/${slug}/logo`, {
        method: 'PATCH',
        body: { uploadToken, uploadUrl: null },
      });
      await fetchWorkspaceDetail(slug);
      toast.add({
        title: '성공',
        description: '로고가 변경되었습니다.',
        color: 'success',
      });
      return true;
    } catch {
      toast.add({
        title: '오류',
        description: '로고 변경에 실패했습니다.',
        color: 'error',
      });
      return false;
    }
  }

  return {
    workspaces,
    isLoading,
    currentSlug,
    currentWorkspace,
    setCurrent,
    fetchWorkspaces,
    createWorkspace,
    fetchWorkspaceDetail,
    currentWorkspaceDetail,
    updateWorkspaceLogo,
  };
});
