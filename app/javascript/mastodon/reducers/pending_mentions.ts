import { createReducer, isAnyOf } from '@reduxjs/toolkit';

import { notificationsUpdate } from 'mastodon/actions/notifications_typed';
import {
  dismissPendingMention,
  expandPendingMentions,
  fetchPendingMentions,
  removePendingMentionByStatus,
} from 'mastodon/actions/pending_mentions';
import type { ApiNotificationGroupJSON } from 'mastodon/api_types/notifications';
import {
  createNotificationGroupFromJSON,
  createNotificationGroupFromNotificationJSON,
} from 'mastodon/models/notification_group';
import type { NotificationGroup } from 'mastodon/models/notification_group';

interface PendingMentionsState {
  groups: NotificationGroup[];
  isLoading: boolean;
  loaded: boolean;
  hasMore: boolean;
  maxId?: string;
}

const initialState: PendingMentionsState = {
  groups: [],
  isLoading: false,
  loaded: false,
  hasMore: true,
};

const normalizeGroups = (groups: ApiNotificationGroupJSON[]) =>
  groups.map(createNotificationGroupFromJSON);

const removeStatus = (state: PendingMentionsState, statusId: string) => {
  state.groups = state.groups.filter(
    (group) => !('statusId' in group) || group.statusId !== statusId,
  );
};

export const pendingMentionsReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(fetchPendingMentions.fulfilled, (state, action) => {
      state.groups = normalizeGroups(action.payload);
      state.loaded = true;
      state.hasMore = action.payload.length > 0;
      state.maxId = action.payload.at(-1)?.page_min_id;
    })
    .addCase(expandPendingMentions.fulfilled, (state, action) => {
      const existing = new Set(state.groups.map((group) => group.group_key));

      state.groups.push(
        ...normalizeGroups(action.payload).filter(
          (group) => !existing.has(group.group_key),
        ),
      );
      state.hasMore = action.payload.length > 0;
      state.maxId = action.payload.at(-1)?.page_min_id;
    })
    .addCase(dismissPendingMention.fulfilled, (state, action) => {
      state.groups = state.groups.filter(
        (group) => group.group_key !== action.payload,
      );
    })
    .addCase(removePendingMentionByStatus, (state, action) => {
      removeStatus(state, action.payload.statusId);
    })
    .addCase(notificationsUpdate, (state, action) => {
      const { notification } = action.payload;

      if (
        state.loaded &&
        notification.type === 'mention' &&
        notification.status?.visibility !== 'direct' &&
        !state.groups.some(
          (group) => group.group_key === notification.group_key,
        )
      ) {
        state.groups.unshift(
          createNotificationGroupFromNotificationJSON(notification),
        );
      }
    })
    .addMatcher(
      isAnyOf(fetchPendingMentions.pending, expandPendingMentions.pending),
      (state) => {
        state.isLoading = true;
      },
    )
    .addMatcher(
      isAnyOf(
        fetchPendingMentions.fulfilled,
        fetchPendingMentions.rejected,
        expandPendingMentions.fulfilled,
        expandPendingMentions.rejected,
      ),
      (state) => {
        state.isLoading = false;
      },
    );
});
