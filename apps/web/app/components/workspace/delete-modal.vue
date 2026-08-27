<script setup lang="ts">
  const isOpen = defineModel<boolean>({ default: false });
  const workspaceStore = useWorkspaceStore();
  const router = useRouter();

  const slug = workspaceStore.currentWorkspace?.slug ?? '';
  const workspace = computed(() => workspaceStore.currentWorkspaceDetail);

  async function onDelete() {
    const { $api } = useNuxtApp();
    try {
      await $api(`/api/v1/workspaces/${slug}`, { method: 'DELETE' });
      isOpen.value = false;
      router.push('/workspaces');
    } catch {
      const toast = useToast();
      toast.add({
        title: '오류',
        description: '워크스페이스 삭제 신청에 실패했습니다.',
        color: 'error',
      });
    }
  }
</script>

<template>
  <UModal v-model:open="isOpen" title="Delete Workspace">
    <template #body>
      <div class="space-y-4">
        <p class="text-sm">
          <span class="font-semibold text-red-500">{{ workspace?.name }}</span> 워크스페이스 삭제를
          신청합니다.
        </p>
        <ul class="text-muted space-y-2 text-sm">
          <li>
            • 삭제 신청 후 <span class="font-semibold text-white">30일</span> 뒤 완전히 삭제됩니다.
          </li>
          <li>• 30일 이내에 취소할 수 있습니다.</li>
          <li>• 연관된 모든 프로젝트와 데이터가 함께 삭제됩니다.</li>
        </ul>
      </div>
    </template>
    <template #footer>
      <div class="flex justify-end gap-2">
        <UButton variant="outline" @click="isOpen = false">취소</UButton>
        <UButton color="error" @click="onDelete">삭제 신청</UButton>
      </div>
    </template>
  </UModal>
</template>
