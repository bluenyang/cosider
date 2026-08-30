<script setup lang="ts">
  const route = useRoute();
  const workspaceStore = useWorkspaceStore();
  const { t } = useI18n();
  const { resolveFileUrl } = useFileUpload();

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
</script>

<template>
  <div>
    <div v-if="workspace">
      <!-- 상단 헤더 -->
      <div class="border-b border-neutral-200 p-6 dark:border-neutral-800">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-4">
            <div
              class="bg-primary flex h-12 w-12 items-center justify-center overflow-hidden rounded-xl text-lg font-bold text-white"
            >
              <img v-if="logoUrl" :src="logoUrl" class="h-full w-full object-cover" />
              <span v-else>{{ workspace.name[0] }}</span>
            </div>
            <div>
              <h1 class="text-xl font-bold">{{ workspace.name }}</h1>
              <p class="text-muted text-sm">{{ workspace.description }}</p>
              <p class="text-muted text-xs">
                @{{ workspace.owner.handle }} ·
                <UBadge :label="workspace.role" variant="outline" size="xs" />
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- 콘텐츠 -->
      <div class="grid grid-cols-5 gap-6 p-6">
        <!-- Projects -->
        <div class="col-span-3">
          <div class="mb-4 flex items-center justify-between">
            <h2 class="font-semibold">{{ t('workspace.home.projects') }}</h2>
            <!-- TODO: 프로젝트 API 완성 후 활성화 -->
            <UButton variant="outline" size="xs" icon="i-lucide-plus" disabled>
              {{ t('workspace.home.newProject') }}
            </UButton>
          </div>
          <UCard>
            <div class="flex flex-col items-center justify-center py-12 text-center">
              <UIcon name="i-lucide-folder" class="text-muted mb-3 text-4xl" />
              <p class="font-medium">{{ t('workspace.home.noProjects') }}</p>
              <p class="text-muted text-sm">{{ t('workspace.home.noProjectsHint') }}</p>
            </div>
          </UCard>
        </div>

        <!-- Recent Activity -->
        <div class="col-span-2">
          <h2 class="mb-4 font-semibold">{{ t('workspace.home.recentActivity') }}</h2>
          <UCard>
            <div class="flex flex-col items-center justify-center py-12 text-center">
              <UIcon name="i-lucide-activity" class="text-muted mb-3 text-4xl" />
              <p class="font-medium">{{ t('workspace.home.noActivity') }}</p>
              <p class="text-muted text-sm">{{ t('workspace.home.noActivityHint') }}</p>
            </div>
          </UCard>
        </div>
      </div>
    </div>
  </div>
</template>
