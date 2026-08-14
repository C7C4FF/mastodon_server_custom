import { createAction } from '@reduxjs/toolkit';

import {
  importFetchedAccounts,
  importFetchedStatuses,
} from 'mastodon/actions/importer';
import {
  apiDismissPendingMention,
  apiFetchNotificationGroups,
} from 'mastodon/api/notifications';
import type { AppDispatch } from 'mastodon/store';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

const importPendingMentions = (
  {
    notifications,
    accounts,
    statuses,
  }: Awaited<ReturnType<typeof apiFetchNotificationGroups>>,
  { dispatch }: { dispatch: AppDispatch },
) => {
  dispatch(importFetchedAccounts(accounts));
  dispatch(importFetchedStatuses(statuses));
  return notifications;
};

export const fetchPendingMentions = createDataLoadingThunk(
  'pendingMentions/fetch',
  () => apiFetchNotificationGroups({ pending_mentions: true }),
  importPendingMentions,
);

export const expandPendingMentions = createDataLoadingThunk(
  'pendingMentions/expand',
  (_params, { getState }) =>
    apiFetchNotificationGroups({
      pending_mentions: true,
      max_id: getState().pendingMentions.maxId,
    }),
  importPendingMentions,
);

export const dismissPendingMention = createDataLoadingThunk(
  'pendingMentions/dismiss',
  async ({ groupKey }: { groupKey: string }) => {
    await apiDismissPendingMention(groupKey);
    return groupKey;
  },
);

export const removePendingMentionByStatus = createAction<{
  statusId: string;
}>('pendingMentions/removeByStatus');
