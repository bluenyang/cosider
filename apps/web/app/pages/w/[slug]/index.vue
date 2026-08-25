<script setup lang="ts">
  const route = useRoute();
  const workspaceStore = useWorkspaceStore();

  const slug = route.params.slug as string;

  await workspaceStore.fetchWorkspaceDetail(slug);

  const workspace = computed(() => workspaceStore.currentWorkspaceDetail);
</script>

<template>
  <div>
    <div v-if="workspace">
      <!-- 상단 헤더 -->
      <div class="border-b border-neutral-200 p-6 dark:border-neutral-800">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-4">
            <div
              class="bg-primary flex h-12 w-12 items-center justify-center rounded-xl text-lg font-bold text-white"
            >
              {{ workspace.name[0] }}
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
            <h2 class="font-semibold">Projects</h2>
            <!-- TODO: 프로젝트 API 완성 후 활성화 -->
            <UButton variant="outline" size="xs" icon="i-lucide-plus" disabled>
              New Project
            </UButton>
          </div>
          <UCard>
            <div class="flex flex-col items-center justify-center py-12 text-center">
              <UIcon name="i-lucide-folder" class="text-muted mb-3 text-4xl" />
              <p class="font-medium">No projects yet</p>
              <p class="text-muted text-sm">Projects will appear here once created.</p>
            </div>
          </UCard>
        </div>

        <!-- Recent Activity -->
        <div class="col-span-2">
          <h2 class="mb-4 font-semibold">Recent Activity</h2>
          <UCard>
            <div class="flex flex-col items-center justify-center py-12 text-center">
              <UIcon name="i-lucide-activity" class="text-muted mb-3 text-4xl" />
              <p class="font-medium">No recent activity</p>
              <p class="text-muted text-sm">Activity will show up as your team works.</p>
            </div>
          </UCard>
        </div>
      </div>
    </div>
  </div>
</template>
