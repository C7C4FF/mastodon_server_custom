import { useCallback, useMemo } from 'react';

import PropTypes from 'prop-types';
import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';
import { Helmet } from '@unhead/react/helmet';
import { Redirect, useLocation } from 'react-router-dom';

import { useSelector } from 'react-redux';

import { Avatar } from 'mastodon/components/avatar';
import ColumnHeader from 'mastodon/components/column_header';
import { useAppHistory } from 'mastodon/components/router';
import { ScrollContainer } from 'mastodon/containers/scroll_container';
import { DirectReplyComposer } from 'mastodon/features/status/components/direct_reply_composer';
import Column from 'mastodon/features/ui/components/column';

const messages = defineMessages({
  participants: { id: 'direct_conversation.participants', defaultMessage: '{count} participants' },
});

const NewConversation = ({ multiColumn }) => {
  const intl = useIntl();
  const history = useAppHistory();
  const location = useLocation();
  const accountIds = location.state?.directAccountIds ?? [];
  const accountsById = useSelector(state => state.get('accounts'));
  const accounts = useMemo(
    () => accountIds.map(id => accountsById.get(id)).filter(Boolean),
    [accountIds, accountsById],
  );

  const handleSend = useCallback(status => {
    history.replace(`/@${status.account.acct}/${status.id}`);
  }, [history]);

  if (accounts.length === 0) {
    return <Redirect to='/conversations' />;
  }

  const headerAccount = accounts[0];
  const headerNames = accounts
    .map(account => account.get('display_name')?.trim() || account.get('username') || account.get('acct'))
    .join(', ');
  const isGroup = accounts.length > 1;

  return (
    <Column bindToDocument={!multiColumn} label={headerNames}>
      <ColumnHeader
        showBackButton
        multiColumn={multiColumn}
        title={(
          <span className='direct-conversation-header'>
            <Avatar account={headerAccount} size={36} className='direct-conversation-header__avatar' />
            <span className='direct-conversation-header__text'>
              <strong>{headerNames}</strong>
              <span>
                {isGroup
                  ? intl.formatMessage(messages.participants, { count: accounts.length + 1 })
                  : `@${headerAccount.get('acct')}`}
              </span>
            </span>
          </span>
        )}
      />

      <ScrollContainer scrollKey='new-direct-conversation'>
        <div className={classNames('item-list scrollable scrollable--flex direct-conversation-thread', { 'direct-conversation-thread--group': isGroup })} />
      </ScrollContainer>

      <DirectReplyComposer recipientAccounts={accounts} onSend={handleSend} />

      <Helmet>
        <title>{headerNames}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

NewConversation.propTypes = {
  multiColumn: PropTypes.bool,
};

export default NewConversation;
