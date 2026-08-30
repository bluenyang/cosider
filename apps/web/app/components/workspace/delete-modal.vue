<script setup lang="ts">
  const isOpen = defineModel<boolean>({ default: false });
  const props = defineProps<{
    slug: string;
  }>();
  const workspaceStore = useWorkspaceStore();
  const router = useRouter();
  const { t } = useI18n();

  const workspace = computed(() => workspaceStore.currentWorkspaceDetail);

  async function onDelete() {
    if (!props.slug) return;
    const success = await workspaceStore.deleteWorkspace(props.slug);
    if (success) {
      isOpen.value = false;
      router.push('/workspaces');
    }
  }
</script>

<template>
  <UModal v-model:open="isOpen" :title="t('workspace.delete.title')">
    <template #body>
      <div class="space-y-4">
        <p class="text-sm">
          {{ t('workspace.delete.confirm', { name: workspace?.name ?? '' }) }}
        </p>
        <ul class="text-muted space-y-2 text-sm">
          <li>{{ t('workspace.delete.delay') }}</li>
          <li>{{ t('workspace.delete.cancelWindow') }}</li>
          <li>{{ t('workspace.delete.cascade') }}</li>
        </ul>
      </div>
    </template>
    <template #footer>
      <div class="flex justify-end gap-2">
        <UButton variant="outline" @click="isOpen = false">{{ t('common.cancel') }}</UButton>
        <UButton color="error" @click="onDelete">{{ t('workspace.delete.submit') }}</UButton>
      </div>
    </template>
  </UModal>
</template>
