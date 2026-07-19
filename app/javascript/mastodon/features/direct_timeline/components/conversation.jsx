import PropTypes from 'prop-types';
import { useCallback } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useHistory } from 'react-router-dom';

import { createSelector } from '@reduxjs/toolkit';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { useDispatch, useSelector } from 'react-redux';

import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import { markAllConversationRead } from 'mastodon/actions/all_conversations';
import { markConversationRead, deleteConversation } from 'mastodon/actions/conversations';
import { muteStatus, unmuteStatus, toggleStatusSpoilers } from 'mastodon/actions/statuses';
import { Hotkeys } from 'mastodon/components/hotkeys';
import AttachmentList from 'mastodon/components/attachment_list';
import AvatarComposite from 'mastodon/components/avatar_composite';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import StatusContent, { getStatusContent } from 'mastodon/components/status_content';
import { Dropdown } from 'mastodon/components/dropdown_menu';
import { makeGetStatus } from 'mastodon/selectors';
import { LinkedDisplayName } from '@/mastodon/components/display_name';
import { AnimateEmojiProvider } from '@/mastodon/components/emoji/context';

const messages = defineMessages({
  more: { id: 'status.more', defaultMessage: 'More' },
  open: { id: 'conversation.open', defaultMessage: 'View conversation' },
  markAsRead: { id: 'conversation.mark_as_read', defaultMessage: 'Mark as read' },
  delete: { id: 'conversation.delete', defaultMessage: 'Delete conversation' },
  muteConversation: { id: 'status.mute_conversation', defaultMessage: 'Mute conversation' },
  unmuteConversation: { id: 'status.unmute_conversation', defaultMessage: 'Unmute conversation' },
});

const getAccounts = createSelector(
  (state) => state.get('accounts'),
  (_, accountIds) => accountIds,
  (accounts, accountIds) =>
    accountIds.map(id => accounts.get(id))
);

const getStatus = makeGetStatus();

export const stripLeadingMentions = (content) => {
  const document = new DOMParser().parseFromString(content, 'text/html');
  const root = document.body.firstElementChild || document.body;
  let removedMention = false;

  while (root.firstChild) {
    if (root.firstChild.nodeType === 1 && root.firstChild.classList.contains('h-card')) {
      root.firstChild.remove();
      removedMention = true;
    } else if (root.firstChild.nodeType === 3 && !root.firstChild.textContent.trim()) {
      root.firstChild.remove();
    } else {
      if (removedMention && root.firstChild.nodeType === 3) {
        root.firstChild.textContent = root.firstChild.textContent.trimStart();
      }

      break;
    }
  }

  return document.body.innerHTML;
};

export const Conversation = ({ conversation, scrollKey, adminMode }) => {
  const id = conversation.get('id');
  const unread = conversation.get('unread');
  const title = conversation.get('title');
  const lastStatusId = conversation.get('last_status');
  const accountIds = conversation.get('accounts');
  const intl = useIntl();
  const dispatch = useDispatch();
  const history = useHistory();
  const lastStatus = useSelector(state => getStatus(state, { id: lastStatusId }));
  const accounts = useSelector(state => getAccounts(state, accountIds));

  const handleClick = useCallback(() => {
    if (unread) {
      dispatch(adminMode ? markAllConversationRead(id) : markConversationRead(id));
    }

    history.push(adminMode ? `/all_conversations/${lastStatus.get('id')}` : `/@${lastStatus.getIn(['account', 'acct'])}/${lastStatus.get('id')}`);
  }, [dispatch, history, unread, adminMode, id, lastStatus]);

  const handleMarkAsRead = useCallback(() => {
    dispatch(adminMode ? markAllConversationRead(id) : markConversationRead(id));
  }, [dispatch, adminMode, id]);

  const handleDelete = useCallback(() => {
    dispatch(deleteConversation(id));
  }, [dispatch, id]);

  const handleConversationMute = useCallback(() => {
    if (lastStatus.get('muted')) {
      dispatch(unmuteStatus(lastStatus.get('id')));
    } else {
      dispatch(muteStatus(lastStatus.get('id')));
    }
  }, [dispatch, lastStatus]);

  const handleShowMore = useCallback(() => {
    dispatch(toggleStatusSpoilers(lastStatus.get('id')));
  }, [dispatch, lastStatus]);

  if (!lastStatus) {
    return null;
  }

  const menu = [
    { text: intl.formatMessage(messages.open), action: handleClick },
  ];

  if (!adminMode) {
    menu.push(
      null,
      { text: intl.formatMessage(lastStatus.get('muted') ? messages.unmuteConversation : messages.muteConversation), action: handleConversationMute }
    );
  }

  if (unread) {
    menu.push({ text: intl.formatMessage(messages.markAsRead), action: handleMarkAsRead });
    menu.push(null);
  }

  if (!adminMode) {
    menu.push({ text: intl.formatMessage(messages.delete), action: handleDelete });
  }

  const names = accounts.map((account) => (
    <LinkedDisplayName displayProps={{account, variant: 'simple'}} key={account.get('id')} />
  )).reduce((prev, cur) => [prev, ', ', cur]);

  const handlers = {
    open: handleClick,
    toggleHidden: handleShowMore,
  };

  return (
    <Hotkeys handlers={handlers}>
      <div className={classNames('conversation focusable muted', { unread })} tabIndex={0}>
        <div className='conversation__avatar' onClick={handleClick} role='presentation'>
          <AvatarComposite accounts={accounts} size={48} />
        </div>

        <div className='conversation__content'>
          <div className='conversation__content__info'>
            <div className='conversation__content__relative-time'>
              {unread && <span className='conversation__unread' />} <RelativeTimestamp timestamp={lastStatus.get('created_at')} />
            </div>

            <AnimateEmojiProvider className={classNames('conversation__content__names', { 'conversation__content__names--custom': title })}>
              {title || <FormattedMessage id='conversation.with' defaultMessage='With {names}' values={{ names: <span>{names}</span> }} />}
            </AnimateEmojiProvider>
          </div>

          <StatusContent
            status={lastStatus}
            statusContent={stripLeadingMentions(getStatusContent(lastStatus))}
            onClick={handleClick}
            expanded={!lastStatus.get('hidden')}
            onExpandedToggle={handleShowMore}
            collapsible
          />

          {lastStatus.get('media_attachments').size > 0 && (
            <AttachmentList
              compact
              media={lastStatus.get('media_attachments')}
              preview={!lastStatus.get('sensitive')}
            />
          )}

          <div className='status__action-bar'>
            <div className='status__action-bar-dropdown'>
              <Dropdown
                scrollKey={scrollKey}
                status={lastStatus}
                items={menu}
                icon='ellipsis-h'
                iconComponent={MoreHorizIcon}
                size={18}
                direction='right'
                title={intl.formatMessage(messages.more)}
              />
            </div>
          </div>
        </div>
      </div>
    </Hotkeys>
  );
};

Conversation.propTypes = {
  conversation: ImmutablePropTypes.map.isRequired,
  scrollKey: PropTypes.string,
  adminMode: PropTypes.bool,
};
