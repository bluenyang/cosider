<script setup lang="ts">
  import type { TabsItem } from '@nuxt/ui';
  import { EFileVisibility, EWorkspaceUserRole } from '@cosider/shared';
  import { useFileUpload } from '~/composables/use-file-upload';

  const route = useRoute();
  const workspaceStore = useWorkspaceStore();
  const toast = useToast();
  const { t } = useI18n();
  const { upload, resolveFileUrl } = useFileUpload();

  const slug = route.params.slug as string;

  await workspaceStore.fetchWorkspaceDetail(slug);

  const workspace = computed(() => workspaceStore.currentWorkspaceDetail);
  const logoUrl = ref<string | null>(null);

  watch(
    () => workspace.value?.logoImageId,
    async (logoImageId) => {
      if (!logoImageId) {
        logoUrl.value = null;
        return;
      }
      logoUrl.value = await resolveFileUrl(logoImageId);
    },
    { immediate: true },
  );

  const logoFile = ref<File | null>(null);
  const previewUrl = ref<string | null>(null);
  const form = reactive({
    name: workspace.value?.name ?? '',
    slug: workspace.value?.slug ?? '',
  });

  watch(workspace, (newVal) => {
    if (!newVal) return;
    form.name = newVal.name;
    form.slug = newVal.slug;
  });

  const isDeleteModalOpen = ref(false);

  watch(logoFile, async (file) => {
    if (!file) return;

    const previousPreviewUrl = previewUrl.value;

    if (previewUrl.value) URL.revokeObjectURL(previewUrl.value);
    previewUrl.value = URL.createObjectURL(file);

    try {
      const { uploadToken } = await upload({
        file,
        endpoint: '/api/v1/files/upload-url',
        visibility: EFileVisibility.PUBLIC,
      });
      const success = await workspaceStore.updateWorkspaceLogo(slug, uploadToken);
      if (!success) {
        previewUrl.value = previousPreviewUrl;
      }
    } catch {
      previewUrl.value = previousPreviewUrl;
      toast.add({
        title: t('common.error'),
        description: t('workspace.create.logoUploadError'),
        color: 'error',
      });
    }
  });

  async function onSave() {
    const success = await workspaceStore.updateWorkspace(slug, {
      name: form.name,
      slug: form.slug,
      description: workspace.value?.description || null,
    });

    if (success && form.slug !== slug) {
      await navigateTo(`/w/${form.slug}/settings`);
    }
  }

  const items = computed<TabsItem[]>(() => {
    const tabs: TabsItem[] = [
      { label: t('workspace.settings.general'), slot: 'general' },
      { label: t('workspace.settings.members'), slot: 'members' },
    ];
    if (workspace.value?.role === EWorkspaceUserRole.OWNER) {
      tabs.push({ label: t('workspace.settings.dangerZone'), slot: 'danger-zone' });
    }
    return tabs;
  });
</script>

<template>
  <div class="p-6">
    <!-- 페이지 헤더 -->
    <div class="mb-6 flex items-center gap-3">
      <UIcon name="i-lucide-settings" class="text-muted text-xl" />
      <div>
        <h1 class="text-xl font-bold">{{ t('workspace.settings.title') }}</h1>
        <p class="text-muted text-sm">{{ t('workspace.settings.description') }}</p>
      </div>
    </div>

    <UTabs :items="items" variant="link">
      <!-- General -->
      <template #general>
        <div class="mt-6 max-w-xl space-y-6">
          <p class="text-muted text-xs font-semibold tracking-widest uppercase">
            {{ t('workspace.settings.profile') }}
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
                class="bg-primary relative flex h-20 w-20 cursor-pointer items-center justify-center overflow-hidden rounded-xl text-2xl font-bold text-white"
                @click="open()"
              >
                <img
                  v-if="previewUrl ?? logoUrl"
                  :src="(previewUrl ?? logoUrl)!"
                  class="h-full w-full object-cover"
                />
                <span v-else>{{ workspace?.name[0] }}</span>
                <!-- 호버 오버레이 -->
                <div
                  class="absolute inset-0 flex items-center justify-center bg-black/40 opacity-0 transition-opacity hover:opacity-100"
                >
                  <UIcon name="i-lucide-camera" class="text-xl text-white" />
                </div>
              </div>
            </UFileUpload>
            <div>
              <p class="font-medium">{{ t('workspace.settings.logo') }}</p>
              <p class="text-muted text-sm">{{ t('workspace.settings.logoHint') }}</p>
            </div>
          </div>

          <!-- 이름 -->
          <UFormField :label="t('workspace.settings.name')">
            <UInput v-model="form.name" class="w-full" />
          </UFormField>

          <!-- URL -->
          <UFormField :label="t('workspace.settings.url')">
            <div class="flex items-center gap-2">
              <span class="text-muted text-sm">{{ t('workspace.settings.urlPrefix') }}</span>
              <UInput v-model="form.slug" class="flex-1" />
            </div>
          </UFormField>

          <div class="flex justify-end">
            <UButton @click="onSave">{{ t('workspace.settings.save') }}</UButton>
          </div>
        </div>
      </template>

      <!-- Members -->
      <template #members>
        <div class="mt-6">
          <!-- TODO: 워크스페이스 멤버 관리 작업에서 구현 -->
          <p class="text-muted text-sm">{{ t('workspace.settings.membersTodo') }}</p>
        </div>
      </template>

      <!-- Danger Zone -->
      <template v-if="workspace?.role === EWorkspaceUserRole.OWNER" #danger-zone>
        <div class="mt-6 max-w-xl">
          <UCard class="border-red-500/30">
            <div class="flex items-center justify-between">
              <div>
                <p class="font-semibold text-red-500">{{ t('workspace.settings.deleteTitle') }}</p>
                <p class="text-muted text-sm">
                  {{ t('workspace.settings.deleteHint') }}
                </p>
              </div>
              <UButton color="error" variant="outline" @click="isDeleteModalOpen = true">
                {{ t('workspace.settings.deleteButton') }}
              </UButton>
            </div>
          </UCard>
          <WorkspaceDeleteModal v-model="isDeleteModalOpen" :slug="slug" />
        </div>
      </template>
    </UTabs>
  </div>
</template>
