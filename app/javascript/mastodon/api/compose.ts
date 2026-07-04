import { apiRequestPut } from 'mastodon/api';
import type { ApiMediaAttachmentJSON } from 'mastodon/api_types/media_attachments';

export const apiUpdateMedia = (
  id: string,
  params?: { account_id?: string | null; description?: string; focus?: string },
) => apiRequestPut<ApiMediaAttachmentJSON>(`v1/media/${id}`, params);
