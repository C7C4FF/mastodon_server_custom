import { useCallback, useEffect, useRef } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';

import ChatBubbleIcon from '@/material-icons/400-24px/chat_bubble.svg?react';
import {
  dismissPendingMention,
  expandPendingMentions,
  fetchPendingMentions,
} from 'mastodon/actions/pending_mentions';
import { Column } from 'mastodon/components/column';
import type { ColumnRef } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import ScrollableList from 'mastodon/components/scrollable_list';
import { NotificationGroup } from 'mastodon/features/notifications_v2/components/notification_group';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  title: {
    id: 'column.pending_mentions',
    defaultMessage: 'Pending mentions',
  },
});

const PendingMentions: React.FC<{ multiColumn?: boolean }> = ({
  multiColumn,
}) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();
  const columnRef = useRef<ColumnRef>(null);
  const groups = useAppSelector((state) => state.pendingMentions.groups);
  const isLoading = useAppSelector((state) => state.pendingMentions.isLoading);
  const hasMore = useAppSelector((state) => state.pendingMentions.hasMore);

  useEffect(() => {
    void dispatch(fetchPendingMentions());
  }, [dispatch]);

  const handleLoadMore = useCallback(() => {
    if (!isLoading) void dispatch(expandPendingMentions());
  }, [dispatch, isLoading]);

  const handleDismiss = useCallback(
    (groupKey: string) => {
      void dispatch(dismissPendingMention({ groupKey }));
    },
    [dispatch],
  );

  const handleHeaderClick = useCallback(() => {
    columnRef.current?.scrollTop();
  }, []);

  const emptyMessage = (
    <FormattedMessage
      id='empty_column.pending_mentions'
      defaultMessage='Mentions waiting for a reply or favorite will appear here.'
    />
  );

  return (
    <Column
      bindToDocument={!multiColumn}
      ref={columnRef}
      label={intl.formatMessage(messages.title)}
      className='notifications-timeline'
    >
      <ColumnHeader
        icon='chat-bubble'
        iconComponent={ChatBubbleIcon}
        title={intl.formatMessage(messages.title)}
        onClick={handleHeaderClick}
        multiColumn={multiColumn}
      />

      <ScrollableList
        scrollKey='pending-mentions'
        isLoading={isLoading}
        showLoading={isLoading && groups.length === 0}
        hasMore={hasMore}
        emptyMessage={emptyMessage}
        onLoadMore={handleLoadMore}
        bindToDocument={!multiColumn}
      >
        {groups.map((group) => (
          <NotificationGroup
            key={group.group_key}
            notificationGroup={group}
            unread={false}
            onDismiss={handleDismiss}
          />
        ))}
      </ScrollableList>

      <Helmet>
        <title>{intl.formatMessage(messages.title)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default PendingMentions;
