<script setup lang="ts">
  import type { TabsItem } from '@nuxt/ui';

  const route = useRoute();
  const workspaceStore = useWorkspaceStore();

  const slug = route.params.slug as string;

  await workspaceStore.fetchWorkspaceDetail(slug);

  const workspace = computed(() => workspaceStore.currentWorkspaceDetail);

  const items: TabsItem[] = [
    { label: 'General', slot: 'general' },
    { label: 'Members', slot: 'members' },
    { label: 'Danger Zone', slot: 'danger-zone' },
  ];
</script>

<template>
  <div class="p-6">
    <!-- 페이지 헤더 -->
    <div class="mb-6 flex items-center gap-3">
      <UIcon name="i-lucide-settings" class="text-muted text-xl" />
      <div>
        <h1 class="text-xl font-bold">Workspace Settings</h1>
        <p class="text-muted text-sm">Manage your team and workspace configurations</p>
      </div>
    </div>

    <UTabs :items="items">
      <!-- General -->
      <template #general>
        <div class="mt-6 max-w-xl space-y-6">
          <p class="text-muted text-xs font-semibold tracking-widest uppercase">
            Workspace Profile
          </p>

          <!-- 로고 -->
          <div class="flex items-center gap-4">
            <div
              class="bg-primary flex h-20 w-20 items-center justify-center rounded-xl text-2xl font-bold text-white"
            >
              {{ workspace?.name[0] }}
            </div>
            <div>
              <p class="font-medium">Workspace Logo</p>
              <p class="text-muted text-sm">We recommend an image of at least 400x400.</p>
              <!-- TODO: 로고 변경 기능 (PATCH /:slug/logo) -->
              <UButton variant="outline" size="xs" class="mt-2" disabled>Change Logo</UButton>
            </div>
          </div>

          <!-- 이름 -->
          <UFormField label="Workspace Name">
            <UInput :model-value="workspace?.name" class="w-full" />
          </UFormField>

          <!-- URL -->
          <UFormField label="Workspace URL">
            <div class="flex items-center gap-2">
              <span class="text-muted text-sm">cosider.app/w/</span>
              <UInput :model-value="workspace?.slug" class="flex-1" />
            </div>
          </UFormField>

          <div class="flex justify-end">
            <!-- TODO: 워크스페이스 정보 수정 기능 (PATCH /:slug) -->
            <UButton disabled>Save Changes</UButton>
          </div>
        </div>
      </template>

      <!-- Members -->
      <template #members>
        <div class="mt-6">
          <!-- TODO: 워크스페이스 멤버 관리 작업에서 구현 -->
          <p class="text-muted text-sm">멤버 관리는 별도 작업에서 구현됩니다.</p>
        </div>
      </template>

      <!-- Danger Zone -->
      <template #danger-zone>
        <div class="mt-6 max-w-xl">
          <UCard class="border-red-500/30">
            <div class="flex items-center justify-between">
              <div>
                <p class="font-semibold text-red-500">Delete Workspace</p>
                <p class="text-muted text-sm">
                  Scheduling deletion will permanently remove all projects, members, and data after
                  24 hours. You can cancel within this window.
                </p>
              </div>
              <!-- TODO: 삭제 신청 모달 연결 (DELETE /:slug) -->
              <UButton color="error" variant="outline">Delete Workspace</UButton>
            </div>
          </UCard>
        </div>
      </template>
    </UTabs>
  </div>
</template>
