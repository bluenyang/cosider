<script setup lang="ts">
  import type { TabsItem } from '@nuxt/ui';
  import { EFileVisibility } from '@cosider/shared';
  import { useFileUpload } from '~/composables/use-file-upload';

  const route = useRoute();
  const workspaceStore = useWorkspaceStore();
  const config = useRuntimeConfig();
  const toast = useToast();
  const { upload } = useFileUpload();

  const slug = route.params.slug as string;

  await workspaceStore.fetchWorkspaceDetail(slug);

  const workspace = computed(() => workspaceStore.currentWorkspaceDetail);
  const logoUrl = computed(() =>
    workspace.value?.logoImageId
      ? `${config.public.apiBase}/api/v1/files/${workspace.value.logoImageId}`
      : null,
  );

  const logoFile = ref<File | null>(null);
  const previewUrl = ref<string | null>(null);
  const form = reactive({
    name: workspace.value?.name ?? '',
    slug: workspace.value?.slug ?? '',
  });

  const isDeleteModalOpen = ref(false);

  watch(logoFile, async (file) => {
    if (!file) return;
    if (previewUrl.value) URL.revokeObjectURL(previewUrl.value);
    previewUrl.value = URL.createObjectURL(file);

    try {
      const { uploadToken } = await upload({
        file,
        endpoint: '/api/v1/files/upload-url',
        visibility: EFileVisibility.PUBLIC,
      });
      await workspaceStore.updateWorkspaceLogo(slug, uploadToken);
    } catch {
      toast.add({
        title: '오류',
        description: '로고 업로드에 실패했습니다.',
        color: 'error',
      });
    }
  });

  async function onSave() {
    await workspaceStore.updateWorkspace(slug, {
      name: form.name,
      slug: form.slug,
      description: workspace.value?.description ?? null,
    });
  }

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

    <UTabs :items="items" variant="link">
      <!-- General -->
      <template #general>
        <div class="mt-6 max-w-xl space-y-6">
          <p class="text-muted text-xs font-semibold tracking-widest uppercase">
            Workspace Profile
          </p>

          <!-- 로고 -->
          <div class="flex items-center gap-4">
            <UFileUpload
              v-slot="{ open }"
              v-model="logoFile"
              accept="image/jpeg,image/png,image/webp"
              :preview="false"
            >
              <div
                class="bg-primary flex h-20 w-20 cursor-pointer items-center justify-center overflow-hidden rounded-xl text-2xl font-bold text-white"
                @click="open()"
              >
                <img
                  v-if="previewUrl ?? logoUrl"
                  :src="(previewUrl ?? logoUrl)!"
                  class="h-full w-full object-cover"
                />
                <span v-else>{{ workspace?.name[0] }}</span>
              </div>
            </UFileUpload>
            <div>
              <p class="font-medium">Workspace Logo</p>
              <p class="text-muted text-sm">We recommend an image of at least 400x400.</p>
            </div>
          </div>

          <!-- 이름 -->
          <UFormField label="Workspace Name">
            <UInput v-model="form.name" class="w-full" />
          </UFormField>

          <!-- URL -->
          <UFormField label="Workspace URL">
            <div class="flex items-center gap-2">
              <span class="text-muted text-sm">cosider.app/w/</span>
              <UInput v-model="form.slug" class="flex-1" />
            </div>
          </UFormField>

          <div class="flex justify-end">
            <UButton @click="onSave">Save Changes</UButton>
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
                  30 days. You can cancel within this window.
                </p>
              </div>
              <UButton color="error" variant="outline" @click="isDeleteModalOpen = true">
                Delete Workspace
              </UButton>
            </div>
          </UCard>
          <WorkspaceDeleteModal v-model="isDeleteModalOpen" />
        </div>
      </template>
    </UTabs>
  </div>
</template>
